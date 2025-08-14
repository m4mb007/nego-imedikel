require 'spec_helper'

RSpec.describe ReferralCode, type: :model do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User', phone: '+1234567890') }
  let(:referral_code) { ReferralCode.create!(user: user) }

  describe 'associations' do
    it 'belongs to a user' do
      expect(referral_code.user).to eq(user)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(referral_code).to be_valid
    end

    it 'has a unique code' do
      expect(referral_code.code).to be_present
      expect(referral_code.code.length).to be_between(6, 20)
    end
  end

  describe 'callbacks' do
    it 'generates a unique code before validation' do
      new_referral_code = ReferralCode.new(user: user)
      new_referral_code.valid?
      expect(new_referral_code.code).to be_present
    end
  end

  describe 'class methods' do
    it 'generates unique codes' do
      code1 = ReferralCode.generate_unique_code
      code2 = ReferralCode.generate_unique_code
      expect(code1).not_to eq(code2)
      expect(code1).to match(/^[A-Z0-9]{8}$/)
    end
  end

  describe 'instance methods' do
    it 'can be deactivated' do
      referral_code.activate!
      expect { referral_code.deactivate! }.to change { referral_code.is_active }.from(true).to(false)
    end

    it 'can be activated' do
      referral_code.deactivate!
      expect { referral_code.activate! }.to change { referral_code.is_active }.from(false).to(true)
    end
  end
end
