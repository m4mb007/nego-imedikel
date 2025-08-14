FactoryBot.define do
  factory :mlm_commission do
    association :user
    association :referrer, factory: :user
    association :order
    level { 1 }
    commission_amount { 10.0 }
    status { 'pending' }
    description { "Level #{level} commission from order ##{order.id}" }

    trait :level_2 do
      level { 2 }
    end

    trait :level_3 do
      level { 3 }
    end

    trait :paid do
      status { 'paid' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end

    trait :voided do
      status { 'voided' }
    end

    trait :high_amount do
      commission_amount { 100.0 }
    end

    trait :low_amount do
      commission_amount { 5.0 }
    end
  end
end
