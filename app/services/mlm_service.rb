class MlmService
  class << self
    def mlm_enabled?
      Setting.get('mlm_enabled', 'true') == 'true'
    end

    def level1_rate
      Setting.get('mlm_level1_rate', 5).to_f / 100.0
    end

    def level2_rate
      Setting.get('mlm_level2_rate', 2).to_f / 100.0
    end

    def level3_rate
      Setting.get('mlm_level3_rate', 1).to_f / 100.0
    end

    def minimum_payout
      Setting.get('mlm_minimum_payout', 50).to_f
    end

    def create_referral(user, referral_code_string)
      return false unless mlm_enabled?
      return false if user.nil? || referral_code_string.blank?

      referral_code = ReferralCode.active.find_by(code: referral_code_string.upcase)
      return false unless referral_code

      referrer = referral_code.user
      return false if user == referrer

      # Check if user is already referred
      return false if Referral.exists?(user: user, status: 'active')

      # Create referral chain
      Referral.create_referral_chain(user, referrer, referral_code)
    end

    def calculate_commission_for_order(order)
      return unless mlm_enabled?
      return unless order.completed?

      # Get platform commission rate
      platform_commission_rate = Setting.get('commission_rate', 5).to_f / 100.0
      
      # Calculate seller's net earnings (after platform commission)
      seller_net_earnings = order.total_amount * (1 - platform_commission_rate)
      
      # Find all active referrals for the order user
      referrals = Referral.where(user: order.user, status: 'active')
      
      referrals.each do |referral|
        commission_rate = case referral.level
                         when 1 then level1_rate
                         when 2 then level2_rate
                         when 3 then level3_rate
                         else 0
                         end

        commission_amount = seller_net_earnings * commission_rate
        
        next if commission_amount <= 0

        MlmCommission.create!(
          user: order.user,
          referrer: referral.referrer,
          order: order,
          level: referral.level,
          commission_amount: commission_amount,
          status: 'pending',
          description: "Level #{referral.level} commission from order ##{order.id}"
        )
      end
    end

    def get_user_referral_stats(user)
      return {} unless user

      {
        total_referrals: user.total_referrals,
        total_earnings: user.total_earnings,
        pending_earnings: user.pending_earnings,
        level1_earnings: user.total_commissions_by_level(1),
        level2_earnings: user.total_commissions_by_level(2),
        level3_earnings: user.total_commissions_by_level(3),
        referral_tree: user.referral_tree
      }
    end

    def process_payout(user, amount = nil)
      return false unless user
      return false unless mlm_enabled?

      pending_commissions = user.earned_commissions.pending
      total_pending = pending_commissions.sum(:commission_amount)
      
      payout_amount = amount || total_pending
      return false if payout_amount < minimum_payout

      # Mark commissions as paid
      pending_commissions.update_all(status: 'paid')
      
      # Create payout record (you might want to create a Payout model)
      # For now, we'll just mark them as paid
      
      true
    end

    def get_commission_summary
      {
        total_pending: MlmCommission.pending.sum(:commission_amount),
        total_paid: MlmCommission.paid.sum(:commission_amount),
        total_cancelled: MlmCommission.cancelled.sum(:commission_amount),
        level1_total: MlmCommission.by_level(1).sum(:commission_amount),
        level2_total: MlmCommission.by_level(2).sum(:commission_amount),
        level3_total: MlmCommission.by_level(3).sum(:commission_amount)
      }
    end

    def void_commissions_for_order(order)
      MlmCommission.where(order: order, status: 'pending').update_all(status: 'voided')
    end

    def cancel_commissions_for_order(order)
      MlmCommission.where(order: order, status: 'pending').update_all(status: 'cancelled')
    end
  end
end
