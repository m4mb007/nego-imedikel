FactoryBot.define do
  factory :referral do
    association :user
    association :referrer, factory: :user
    association :referral_code
    level { 1 }
    status { 'active' }

    trait :level_2 do
      level { 2 }
    end

    trait :level_3 do
      level { 3 }
    end

    trait :inactive do
      status { 'inactive' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end
  end
end
