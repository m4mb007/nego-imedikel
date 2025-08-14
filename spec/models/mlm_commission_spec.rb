require 'spec_helper'

RSpec.describe MlmCommission, type: :model do
  let(:user) { create(:user) }
  let(:referrer) { create(:user) }
  let(:order) { create(:order, user: user, status: 'delivered') }
  let(:commission) { create(:mlm_commission, user: user, referrer: referrer, order: order) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:referrer).class_name('User') }
    it { should belong_to(:order) }
  end

  describe 'validations' do
    it { should validate_presence_of(:level) }
    it { should validate_numericality_of(:level).is_greater_than(0).is_less_than_or_equal_to(3) }
    it { should validate_presence_of(:commission_amount) }
    it { should validate_numericality_of(:commission_amount).is_greater_than(0) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[pending paid cancelled voided]) }
  end

  describe 'scopes' do
    let!(:pending_commission) { create(:mlm_commission, status: 'pending') }
    let!(:paid_commission) { create(:mlm_commission, status: 'paid') }
    let!(:cancelled_commission) { create(:mlm_commission, status: 'cancelled') }
    let!(:voided_commission) { create(:mlm_commission, status: 'voided') }

    describe '.pending' do
      it 'returns only pending commissions' do
        expect(MlmCommission.pending).to include(pending_commission)
        expect(MlmCommission.pending).not_to include(paid_commission, cancelled_commission, voided_commission)
      end
    end

    describe '.paid' do
      it 'returns only paid commissions' do
        expect(MlmCommission.paid).to include(paid_commission)
        expect(MlmCommission.paid).not_to include(pending_commission, cancelled_commission, voided_commission)
      end
    end

    describe '.cancelled' do
      it 'returns only cancelled commissions' do
        expect(MlmCommission.cancelled).to include(cancelled_commission)
        expect(MlmCommission.cancelled).not_to include(pending_commission, paid_commission, voided_commission)
      end
    end

    describe '.voided' do
      it 'returns only voided commissions' do
        expect(MlmCommission.voided).to include(voided_commission)
        expect(MlmCommission.voided).not_to include(pending_commission, paid_commission, cancelled_commission)
      end
    end

    describe '.by_level' do
      it 'returns commissions by level' do
        level1_commission = create(:mlm_commission, level: 1)
        level2_commission = create(:mlm_commission, level: 2)
        expect(MlmCommission.by_level(1)).to include(level1_commission)
        expect(MlmCommission.by_level(1)).not_to include(level2_commission)
      end
    end

    describe '.recent' do
      it 'returns commissions ordered by created_at desc' do
        old_commission = create(:mlm_commission, created_at: 1.day.ago)
        new_commission = create(:mlm_commission, created_at: 1.hour.ago)
        expect(MlmCommission.recent.first).to eq(new_commission)
        expect(MlmCommission.recent.last).to eq(old_commission)
      end
    end
  end

  describe 'class methods' do
    describe '.calculate_commission_for_order' do
      let(:order) { create(:order, user: user, total_amount: 100.0, status: 'delivered') }
      let(:referral) { create(:referral, user: user, referrer: referrer, level: 1, status: 'active') }

      before do
        Setting.set('commission_rate', '5') # 5% platform commission
        Setting.set('mlm_level1_rate', '5') # 5% level 1 commission
        Setting.set('mlm_level2_rate', '2') # 2% level 2 commission
        Setting.set('mlm_level3_rate', '1') # 1% level 3 commission
      end

      context 'when order is completed' do
        it 'creates commission records for active referrals' do
          referral # Create the referral
          
          expect {
            MlmCommission.calculate_commission_for_order(order)
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
            MlmCommission.calculate_commission_for_order(order)
          }.not_to change(MlmCommission, :count)
        end

        it 'creates commissions for multiple levels' do
          user2 = create(:user)
          referral2 = create(:referral, user: user, referrer: user2, level: 2, status: 'active')
          
          expect {
            MlmCommission.calculate_commission_for_order(order)
          }.to change(MlmCommission, :count).by(2)

          commissions = MlmCommission.where(order: order)
          expect(commissions.map(&:level)).to contain_exactly(1, 2)
        end
      end

      context 'when order is not completed' do
        it 'does not create commission records' do
          order.update!(status: 'pending')
          
          expect {
            MlmCommission.calculate_commission_for_order(order)
          }.not_to change(MlmCommission, :count)
        end
      end
    end

    describe '.void_commissions_for_order' do
      let!(:pending_commission) { create(:mlm_commission, order: order, status: 'pending') }
      let!(:paid_commission) { create(:mlm_commission, order: order, status: 'paid') }

      it 'voids only pending commissions for the order' do
        MlmCommission.void_commissions_for_order(order)
        
        expect(pending_commission.reload.status).to eq('voided')
        expect(paid_commission.reload.status).to eq('paid') # Should remain unchanged
      end
    end

    describe '.cancel_commissions_for_order' do
      let!(:pending_commission) { create(:mlm_commission, order: order, status: 'pending') }
      let!(:paid_commission) { create(:mlm_commission, order: order, status: 'paid') }

      it 'cancels only pending commissions for the order' do
        MlmCommission.cancel_commissions_for_order(order)
        
        expect(pending_commission.reload.status).to eq('cancelled')
        expect(paid_commission.reload.status).to eq('paid') # Should remain unchanged
      end
    end
  end

  describe 'instance methods' do
    describe '#mark_as_paid!' do
      it 'sets status to paid' do
        expect { commission.mark_as_paid! }.to change { commission.status }.from('pending').to('paid')
      end
    end

    describe '#void!' do
      it 'sets status to voided' do
        expect { commission.void! }.to change { commission.status }.from('pending').to('voided')
      end
    end

    describe '#cancel!' do
      it 'sets status to cancelled' do
        expect { commission.cancel! }.to change { commission.status }.from('pending').to('cancelled')
      end
    end

    describe '#pending?' do
      it 'returns true for pending commissions' do
        expect(commission.pending?).to be true
      end

      it 'returns false for non-pending commissions' do
        commission.update!(status: 'paid')
        expect(commission.pending?).to be false
      end
    end

    describe '#paid?' do
      it 'returns true for paid commissions' do
        commission.update!(status: 'paid')
        expect(commission.paid?).to be true
      end

      it 'returns false for non-paid commissions' do
        expect(commission.paid?).to be false
      end
    end

    describe '#cancelled?' do
      it 'returns true for cancelled commissions' do
        commission.update!(status: 'cancelled')
        expect(commission.cancelled?).to be true
      end

      it 'returns false for non-cancelled commissions' do
        expect(commission.cancelled?).to be false
      end
    end

    describe '#voided?' do
      it 'returns true for voided commissions' do
        commission.update!(status: 'voided')
        expect(commission.voided?).to be true
      end

      it 'returns false for non-voided commissions' do
        expect(commission.voided?).to be false
      end
    end

    describe '#formatted_amount' do
      it 'returns formatted commission amount' do
        commission.update!(commission_amount: 10.50)
        expect(commission.formatted_amount).to eq('RM10.5')
      end
    end

    describe '#formatted_date' do
      it 'returns formatted creation date' do
        commission.update!(created_at: Time.new(2023, 1, 15, 14, 30, 0))
        expect(commission.formatted_date).to eq('January 15, 2023 at 02:30 PM')
      end
    end
  end
end
