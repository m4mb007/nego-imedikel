require 'spec_helper'

RSpec.describe MlmService, type: :service do
  let(:user) { create(:user) }
  let(:referrer) { create(:user) }
  let(:order) { create(:order, user: user, total_amount: 100.0, status: 'delivered') }

  before do
    Setting.set('mlm_enabled', 'true')
    Setting.set('commission_rate', '5')
    Setting.set('mlm_level1_rate', '5')
    Setting.set('mlm_level2_rate', '2')
    Setting.set('mlm_level3_rate', '1')
    Setting.set('mlm_minimum_payout', '50')
  end

  describe '.mlm_enabled?' do
    it 'returns true when MLM is enabled' do
      expect(MlmService.mlm_enabled?).to be true
    end

    it 'returns false when MLM is disabled' do
      Setting.set('mlm_enabled', 'false')
      expect(MlmService.mlm_enabled?).to be false
    end
  end

  describe '.level1_rate' do
    it 'returns the level 1 commission rate' do
      expect(MlmService.level1_rate).to eq(0.05)
    end
  end

  describe '.level2_rate' do
    it 'returns the level 2 commission rate' do
      expect(MlmService.level2_rate).to eq(0.02)
    end
  end

  describe '.level3_rate' do
    it 'returns the level 3 commission rate' do
      expect(MlmService.level3_rate).to eq(0.01)
    end
  end

  describe '.minimum_payout' do
    it 'returns the minimum payout amount' do
      expect(MlmService.minimum_payout).to eq(50.0)
    end
  end

  describe '.create_referral' do
    let(:referral_code) { create(:referral_code, user: referrer) }

    context 'when MLM is enabled' do
      it 'creates a referral when valid code is provided' do
        result = MlmService.create_referral(user, referral_code.code)
        expect(result).to be_a(Referral)
        expect(result.user).to eq(user)
        expect(result.referrer).to eq(referrer)
        expect(result.level).to eq(1)
      end

      it 'returns false when user tries to refer themselves' do
        result = MlmService.create_referral(referrer, referral_code.code)
        expect(result).to be false
      end

      it 'returns false when user is already referred' do
        create(:referral, user: user, referrer: referrer, status: 'active')
        result = MlmService.create_referral(user, referral_code.code)
        expect(result).to be false
      end

      it 'returns false when referral code is invalid' do
        result = MlmService.create_referral(user, 'INVALID')
        expect(result).to be false
      end

      it 'returns false when referral code is inactive' do
        referral_code.update!(is_active: false)
        result = MlmService.create_referral(user, referral_code.code)
        expect(result).to be false
      end
    end

    context 'when MLM is disabled' do
      before { Setting.set('mlm_enabled', 'false') }

      it 'returns false' do
        result = MlmService.create_referral(user, referral_code.code)
        expect(result).to be false
      end
    end
  end

  describe '.calculate_commission_for_order' do
    let(:referral) { create(:referral, user: user, referrer: referrer, level: 1, status: 'active') }

    context 'when MLM is enabled and order is completed' do
      it 'creates commission records for active referrals' do
        referral # Create the referral
        
        expect {
          MlmService.calculate_commission_for_order(order)
        }.to change(MlmCommission, :count).by(1)

        commission = MlmCommission.last
        expect(commission.user).to eq(user)
        expect(commission.referrer).to eq(referrer)
        expect(commission.order).to eq(order)
        expect(commission.level).to eq(1)
        expect(commission.status).to eq('pending')
        # Seller net earnings = 100 * (1 - 0.05) = 95
        # Commission = 95 * 0.05 = 4.75
        expect(commission.commission_amount).to eq(4.75)
      end

      it 'does not create commissions for inactive referrals' do
        referral.update!(status: 'cancelled')
        
        expect {
          MlmService.calculate_commission_for_order(order)
        }.not_to change(MlmCommission, :count)
      end
    end

    context 'when MLM is disabled' do
      before { Setting.set('mlm_enabled', 'false') }

      it 'does not create commission records' do
        referral
        
        expect {
          MlmService.calculate_commission_for_order(order)
        }.not_to change(MlmCommission, :count)
      end
    end

    context 'when order is not completed' do
      it 'does not create commission records' do
        order.update!(status: 'pending')
        referral
        
        expect {
          MlmService.calculate_commission_for_order(order)
        }.not_to change(MlmCommission, :count)
      end
    end
  end

  describe '.get_user_referral_stats' do
    let(:referral) { create(:referral, user: user, referrer: referrer, level: 1, status: 'active') }
    let!(:commission1) { create(:mlm_commission, user: user, referrer: referrer, level: 1, status: 'paid', commission_amount: 10.0) }
    let!(:commission2) { create(:mlm_commission, user: user, referrer: referrer, level: 1, status: 'pending', commission_amount: 5.0) }

    it 'returns referral statistics for the user' do
      stats = MlmService.get_user_referral_stats(referrer)
      
      expect(stats[:total_referrals]).to eq(1)
      expect(stats[:total_earnings]).to eq(10.0)
      expect(stats[:pending_earnings]).to eq(5.0)
      expect(stats[:level1_earnings]).to eq(10.0)
      expect(stats[:level2_earnings]).to eq(0.0)
      expect(stats[:level3_earnings]).to eq(0.0)
      expect(stats[:referral_tree]).to be_a(Hash)
    end

    it 'returns empty hash when user is nil' do
      stats = MlmService.get_user_referral_stats(nil)
      expect(stats).to eq({})
    end
  end

  describe '.process_payout' do
    let!(:pending_commission1) { create(:mlm_commission, user: user, referrer: referrer, status: 'pending', commission_amount: 30.0) }
    let!(:pending_commission2) { create(:mlm_commission, user: user, referrer: referrer, status: 'pending', commission_amount: 25.0) }
    let!(:paid_commission) { create(:mlm_commission, user: user, referrer: referrer, status: 'paid', commission_amount: 10.0) }

    context 'when MLM is enabled' do
      it 'processes payout for all pending commissions' do
        result = MlmService.process_payout(referrer)
        expect(result).to be true
        
        expect(pending_commission1.reload.status).to eq('paid')
        expect(pending_commission2.reload.status).to eq('paid')
        expect(paid_commission.reload.status).to eq('paid') # Should remain unchanged
      end

      it 'processes payout for specified amount' do
        result = MlmService.process_payout(referrer, 30.0)
        expect(result).to be true
        
        expect(pending_commission1.reload.status).to eq('paid')
        expect(pending_commission2.reload.status).to eq('pending') # Should remain unchanged
      end

      it 'returns false when amount is below minimum payout' do
        result = MlmService.process_payout(referrer, 25.0)
        expect(result).to be false
        
        expect(pending_commission1.reload.status).to eq('pending')
        expect(pending_commission2.reload.status).to eq('pending')
      end
    end

    context 'when MLM is disabled' do
      before { Setting.set('mlm_enabled', 'false') }

      it 'returns false' do
        result = MlmService.process_payout(referrer)
        expect(result).to be false
        
        expect(pending_commission1.reload.status).to eq('pending')
        expect(pending_commission2.reload.status).to eq('pending')
      end
    end
  end

  describe '.get_commission_summary' do
    let!(:pending_commission) { create(:mlm_commission, status: 'pending', commission_amount: 10.0) }
    let!(:paid_commission) { create(:mlm_commission, status: 'paid', commission_amount: 20.0) }
    let!(:cancelled_commission) { create(:mlm_commission, status: 'cancelled', commission_amount: 5.0) }
    let!(:level1_commission) { create(:mlm_commission, level: 1, commission_amount: 15.0) }
    let!(:level2_commission) { create(:mlm_commission, level: 2, commission_amount: 8.0) }
    let!(:level3_commission) { create(:mlm_commission, level: 3, commission_amount: 3.0) }

    it 'returns commission summary statistics' do
      summary = MlmService.get_commission_summary
      
      expect(summary[:total_pending]).to eq(10.0)
      expect(summary[:total_paid]).to eq(20.0)
      expect(summary[:total_cancelled]).to eq(5.0)
      expect(summary[:level1_total]).to eq(15.0)
      expect(summary[:level2_total]).to eq(8.0)
      expect(summary[:level3_total]).to eq(3.0)
    end
  end

  describe '.void_commissions_for_order' do
    let!(:pending_commission) { create(:mlm_commission, order: order, status: 'pending') }
    let!(:paid_commission) { create(:mlm_commission, order: order, status: 'paid') }

    it 'voids only pending commissions for the order' do
      MlmService.void_commissions_for_order(order)
      
      expect(pending_commission.reload.status).to eq('voided')
      expect(paid_commission.reload.status).to eq('paid') # Should remain unchanged
    end
  end

  describe '.cancel_commissions_for_order' do
    let!(:pending_commission) { create(:mlm_commission, order: order, status: 'pending') }
    let!(:paid_commission) { create(:mlm_commission, order: order, status: 'paid') }

    it 'cancels only pending commissions for the order' do
      MlmService.cancel_commissions_for_order(order)
      
      expect(pending_commission.reload.status).to eq('cancelled')
      expect(paid_commission.reload.status).to eq('paid') # Should remain unchanged
    end
  end
end
