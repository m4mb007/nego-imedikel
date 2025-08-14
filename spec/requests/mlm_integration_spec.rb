require 'spec_helper'

RSpec.describe 'MLM Integration', type: :request do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:user3) { create(:user) }
  let(:store) { create(:store, user: user1) }
  let(:product) { create(:product, user: user1, store: store) }

  before do
    Setting.set('mlm_enabled', 'true')
    Setting.set('commission_rate', '5')
    Setting.set('mlm_level1_rate', '5')
    Setting.set('mlm_level2_rate', '2')
    Setting.set('mlm_level3_rate', '1')
  end

  describe 'Complete MLM Workflow' do
    it 'creates a complete referral chain and calculates commissions' do
      # Step 1: Create referral codes for users
      referral_code1 = user1.referral_code_or_create
      referral_code2 = user2.referral_code_or_create
      referral_code3 = user3.referral_code_or_create

      expect(referral_code1.code).to be_present
      expect(referral_code2.code).to be_present
      expect(referral_code3.code).to be_present

      # Step 2: Create referral chain (user1 -> user2 -> user3)
      sign_in user2
      post apply_referral_path, params: { referral_code: referral_code1.code }
      sign_out user2

      sign_in user3
      post apply_referral_path, params: { referral_code: referral_code2.code }
      sign_out user3

      # Step 3: Verify referral relationships
      expect(user1.referred_users.count).to eq(1) # user2
      expect(user2.referred_users.count).to eq(1) # user3
      expect(user3.referrals.count).to eq(2) # user2 (level 1) and user1 (level 2)

      # Step 4: Create an order for user3
      order = create(:order, user: user3, store: store, total_amount: 100.0, status: 'delivered')

      # Step 5: Calculate commissions
      MlmService.calculate_commission_for_order(order)

      # Step 6: Verify commissions were created
      commissions = MlmCommission.where(order: order)
      expect(commissions.count).to eq(2)

      # Level 1 commission (user2 gets commission from user3's order)
      level1_commission = commissions.find_by(level: 1)
      expect(level1_commission).to be_present
      expect(level1_commission.referrer).to eq(user2)
      expect(level1_commission.user).to eq(user3)
      expect(level1_commission.commission_amount).to eq(4.75) # 95 * 0.05

      # Level 2 commission (user1 gets commission from user3's order)
      level2_commission = commissions.find_by(level: 2)
      expect(level2_commission).to be_present
      expect(level2_commission.referrer).to eq(user1)
      expect(level2_commission.user).to eq(user3)
      expect(level2_commission.commission_amount).to eq(1.90) # 95 * 0.02

      # Step 7: Verify user statistics
      user1_stats = MlmService.get_user_referral_stats(user1)
      expect(user1_stats[:total_referrals]).to eq(1)
      expect(user1_stats[:total_earnings]).to eq(0.0) # Not paid yet
      expect(user1_stats[:pending_earnings]).to eq(1.90)

      user2_stats = MlmService.get_user_referral_stats(user2)
      expect(user2_stats[:total_referrals]).to eq(1)
      expect(user2_stats[:total_earnings]).to eq(0.0) # Not paid yet
      expect(user2_stats[:pending_earnings]).to eq(4.75)
    end
  end

  describe 'Commission Calculation Edge Cases' do
    it 'handles order cancellation correctly' do
      # Setup referral
      referral_code = user1.referral_code_or_create
      sign_in user2
      post apply_referral_path, params: { referral_code: referral_code.code }
      sign_out user2

      # Create order and calculate commissions
      order = create(:order, user: user2, store: store, total_amount: 100.0, status: 'delivered')
      MlmService.calculate_commission_for_order(order)

      # Verify commission was created
      commission = MlmCommission.find_by(order: order)
      expect(commission).to be_present
      expect(commission.status).to eq('pending')

      # Cancel the order
      order.update!(status: 'cancelled')
      MlmService.cancel_commissions_for_order(order)

      # Verify commission was cancelled
      expect(commission.reload.status).to eq('cancelled')
    end

    it 'handles order refund correctly' do
      # Setup referral
      referral_code = user1.referral_code_or_create
      sign_in user2
      post apply_referral_path, params: { referral_code: referral_code.code }
      sign_out user2

      # Create order and calculate commissions
      order = create(:order, user: user2, store: store, total_amount: 100.0, status: 'delivered')
      MlmService.calculate_commission_for_order(order)

      # Verify commission was created
      commission = MlmCommission.find_by(order: order)
      expect(commission).to be_present
      expect(commission.status).to eq('pending')

      # Refund the order
      order.update!(status: 'refunded')
      MlmService.void_commissions_for_order(order)

      # Verify commission was voided
      expect(commission.reload.status).to eq('voided')
    end

    it 'does not create commissions for inactive referrals' do
      # Setup referral
      referral_code = user1.referral_code_or_create
      sign_in user2
      post apply_referral_path, params: { referral_code: referral_code.code }
      sign_out user2

      # Cancel the referral
      referral = Referral.find_by(user: user2, referrer: user1)
      referral.cancel!

      # Create order and calculate commissions
      order = create(:order, user: user2, store: store, total_amount: 100.0, status: 'delivered')
      MlmService.calculate_commission_for_order(order)

      # Verify no commission was created
      expect(MlmCommission.where(order: order)).to be_empty
    end
  end

  describe 'Payout Processing' do
    it 'processes payouts correctly' do
      # Setup referral and commissions
      referral_code = user1.referral_code_or_create
      sign_in user2
      post apply_referral_path, params: { referral_code: referral_code.code }
      sign_out user2

      order = create(:order, user: user2, store: store, total_amount: 100.0, status: 'delivered')
      MlmService.calculate_commission_for_order(order)

      commission = MlmCommission.find_by(order: order)
      expect(commission.status).to eq('pending')

      # Process payout
      sign_in user1
      patch process_payout_admin_mlm_index_path, params: { user_id: user1.id, amount: 5.0 }
      sign_out user1

      # Verify commission was paid
      expect(commission.reload.status).to eq('paid')
    end

    it 'enforces minimum payout amount' do
      # Setup referral and commissions
      referral_code = user1.referral_code_or_create
      sign_in user2
      post apply_referral_path, params: { referral_code: referral_code.code }
      sign_out user2

      order = create(:order, user: user2, store: store, total_amount: 50.0, status: 'delivered')
      MlmService.calculate_commission_for_order(order)

      commission = MlmCommission.find_by(order: order)
      expect(commission.status).to eq('pending')

      # Try to process payout below minimum
      sign_in user1
      patch process_payout_admin_mlm_index_path, params: { user_id: user1.id, amount: 1.0 }
      sign_out user1

      # Verify commission remains pending
      expect(commission.reload.status).to eq('pending')
    end
  end

  describe 'MLM Settings' do
    it 'respects MLM enable/disable setting' do
      # Disable MLM
      Setting.set('mlm_enabled', 'false')

      # Try to create referral
      referral_code = user1.referral_code_or_create
      sign_in user2
      post apply_referral_path, params: { referral_code: referral_code.code }
      sign_out user2

      # Verify no referral was created
      expect(Referral.count).to eq(0)

      # Enable MLM
      Setting.set('mlm_enabled', 'true')

      # Try to create referral again
      sign_in user2
      post apply_referral_path, params: { referral_code: referral_code.code }
      sign_out user2

      # Verify referral was created
      expect(Referral.count).to eq(1)
    end

    it 'uses correct commission rates from settings' do
      # Change commission rates
      Setting.set('mlm_level1_rate', '10') # 10%
      Setting.set('mlm_level2_rate', '5')  # 5%

      # Setup referral
      referral_code = user1.referral_code_or_create
      sign_in user2
      post apply_referral_path, params: { referral_code: referral_code.code }
      sign_out user2

      # Create order and calculate commissions
      order = create(:order, user: user2, store: store, total_amount: 100.0, status: 'delivered')
      MlmService.calculate_commission_for_order(order)

      # Verify commission uses new rate
      commission = MlmCommission.find_by(order: order)
      expect(commission.commission_amount).to eq(9.5) # 95 * 0.10
    end
  end
end
