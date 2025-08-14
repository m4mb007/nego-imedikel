class MlmCommission < ApplicationRecord
  belongs_to :user
  belongs_to :referrer, class_name: 'User'
  belongs_to :order

  validates :level, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 3 }
  validates :commission_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending paid cancelled voided] }

  scope :pending, -> { where(status: 'pending') }
  scope :paid, -> { where(status: 'paid') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :voided, -> { where(status: 'voided') }
  scope :by_level, ->(level) { where(level: level) }
  scope :recent, -> { order(created_at: :desc) }

  def self.calculate_commission_for_order(order)
    return unless order.completed?

    # Get platform commission rate from settings
    platform_commission_rate = Setting.get('commission_rate', 5).to_f / 100.0
    
    # Calculate seller's net earnings (after platform commission)
    seller_net_earnings = order.total_amount * (1 - platform_commission_rate)
    
    # Get MLM commission rates from settings
    level1_rate = Setting.get('mlm_level1_rate', 5).to_f / 100.0
    level2_rate = Setting.get('mlm_level2_rate', 2).to_f / 100.0
    level3_rate = Setting.get('mlm_level3_rate', 1).to_f / 100.0

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

      create!(
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

  def self.void_commissions_for_order(order)
    where(order: order, status: 'pending').update_all(status: 'voided')
  end

  def self.cancel_commissions_for_order(order)
    where(order: order, status: 'pending').update_all(status: 'cancelled')
  end

  def mark_as_paid!
    update!(status: 'paid')
  end

  def void!
    update!(status: 'voided')
  end

  def cancel!
    update!(status: 'cancelled')
  end

  def pending?
    status == 'pending'
  end

  def paid?
    status == 'paid'
  end

  def cancelled?
    status == 'cancelled'
  end

  def voided?
    status == 'voided'
  end

  def formatted_amount
    "RM#{commission_amount}"
  end

  def formatted_date
    created_at.strftime("%B %d, %Y at %I:%M %p")
  end
end
