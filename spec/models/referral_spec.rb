require 'spec_helper'

RSpec.describe Referral, type: :model do
  let(:user) { create(:user) }
  let(:referrer) { create(:user) }
  let(:referral_code) { create(:referral_code, user: referrer) }
  let(:referral) { create(:referral, user: user, referrer: referrer, referral_code: referral_code) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:referrer).class_name('User') }
    it { should belong_to(:referral_code) }
  end

  describe 'validations' do
    it { should validate_presence_of(:level) }
    it { should validate_numericality_of(:level).is_greater_than(0).is_less_than_or_equal_to(3) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[active inactive cancelled]) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:referrer_id).with_message("can only be referred once by the same person") }
  end

  describe 'scopes' do
    let!(:active_referral) { create(:referral, status: 'active') }
    let!(:inactive_referral) { create(:referral, status: 'inactive') }
    let!(:cancelled_referral) { create(:referral, status: 'cancelled') }

    describe '.active' do
      it 'returns only active referrals' do
        expect(Referral.active).to include(active_referral)
        expect(Referral.active).not_to include(inactive_referral, cancelled_referral)
      end
    end

    describe '.inactive' do
      it 'returns only inactive referrals' do
        expect(Referral.inactive).to include(inactive_referral)
        expect(Referral.inactive).not_to include(active_referral, cancelled_referral)
      end
    end

    describe '.cancelled' do
      it 'returns only cancelled referrals' do
        expect(Referral.cancelled).to include(cancelled_referral)
        expect(Referral.cancelled).not_to include(active_referral, inactive_referral)
      end
    end

    describe '.by_level' do
      it 'returns referrals by level' do
        level1_referral = create(:referral, level: 1)
        level2_referral = create(:referral, level: 2)
        expect(Referral.by_level(1)).to include(level1_referral)
        expect(Referral.by_level(1)).not_to include(level2_referral)
      end
    end

    describe '.recent' do
      it 'returns referrals ordered by created_at desc' do
        old_referral = create(:referral, created_at: 2.days.ago)
        new_referral = create(:referral, created_at: 1.day.ago)
        
        expect(Referral.recent.first).to eq(new_referral)
        expect(Referral.recent.last).to eq(old_referral)
      end
    end
  end

  describe 'class methods' do
    describe '.create_referral_chain' do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }
      let(:user3) { create(:user) }
      let(:referral_code1) { create(:referral_code, user: user1) }
      let(:referral_code2) { create(:referral_code, user: user2) }

      context 'when creating a simple referral' do
        it 'creates a level 1 referral' do
          result = Referral.create_referral_chain(user2, user1, referral_code1)
          expect(result).to be_a(Referral)
          expect(result.level).to eq(1)
          expect(result.status).to eq('active')
          expect(result.user).to eq(user2)
          expect(result.referrer).to eq(user1)
        end

        it 'returns false if user tries to refer themselves' do
          result = Referral.create_referral_chain(user1, user1, referral_code1)
          expect(result).to be false
        end
      end

      context 'when creating a multi-level referral chain' do
        before do
          # User2 is referred by User1
          Referral.create_referral_chain(user2, user1, referral_code1)
        end

        it 'creates level 1 and level 2 referrals when user3 is referred by user2' do
          result = Referral.create_referral_chain(user3, user2, referral_code2)
          
          expect(result).to be_a(Referral)
          expect(result.level).to eq(1)
          
          # Check that level 2 referral was created
          level2_referral = Referral.find_by(user: user3, referrer: user1, level: 2)
          expect(level2_referral).to be_present
          expect(level2_referral.status).to eq('active')
        end

        it 'creates level 1, 2, and 3 referrals for a complete chain' do
          user4 = create(:user)
          referral_code3 = create(:referral_code, user: user3)
          
          result = Referral.create_referral_chain(user4, user3, referral_code3)
          
          expect(result).to be_a(Referral)
          expect(result.level).to eq(1)
          
          # Check level 2 referral (user4 -> user2)
          level2_referral = Referral.find_by(user: user4, referrer: user2, level: 2)
          expect(level2_referral).to be_present
          
          # Check level 3 referral (user4 -> user1)
          level3_referral = Referral.find_by(user: user4, referrer: user1, level: 3)
          expect(level3_referral).to be_present
        end
      end
    end
  end

  describe 'instance methods' do
    describe '#cancel!' do
      it 'sets status to cancelled and cancels associated commissions' do
        commission = create(:mlm_commission, user: user, referrer: referrer, level: referral.level)
        
        expect { referral.cancel! }.to change { referral.status }.from('active').to('cancelled')
        expect(commission.reload.status).to eq('cancelled')
      end
    end

    describe '#reactivate!' do
      it 'sets status to active' do
        referral.update!(status: 'cancelled')
        expect { referral.reactivate! }.to change { referral.status }.from('cancelled').to('active')
      end
    end

    describe '#active?' do
      it 'returns true for active referrals' do
        expect(referral.active?).to be true
      end

      it 'returns false for inactive referrals' do
        referral.update!(status: 'inactive')
        expect(referral.active?).to be false
      end
    end

    describe '#cancelled?' do
      it 'returns true for cancelled referrals' do
        referral.update!(status: 'cancelled')
        expect(referral.cancelled?).to be true
      end

      it 'returns false for active referrals' do
        expect(referral.cancelled?).to be false
      end
    end
  end
end
