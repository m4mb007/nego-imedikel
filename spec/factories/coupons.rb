FactoryBot.define do
  factory :coupon do
    code { "MyString" }
    discount_type { 1 }
    discount_value { "9.99" }
    minimum_amount { "9.99" }
    maximum_discount { "9.99" }
    usage_limit { 1 }
    used_count { 1 }
    valid_from { "2025-08-12 12:20:16" }
    valid_until { "2025-08-12 12:20:16" }
    status { 1 }
  end
end
