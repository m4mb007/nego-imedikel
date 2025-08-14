FactoryBot.define do
  factory :referral_code do
    association :user
    code { SecureRandom.alphanumeric(8).upcase }
    is_active { true }

    trait :inactive do
      is_active { false }
    end

    trait :with_referrals do
      after(:create) do |referral_code|
        create_list(:referral, 3, referral_code: referral_code)
      end
    end
  end
end
