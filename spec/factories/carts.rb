FactoryBot.define do
  factory :cart do
    association :user
    association :product
    product_variant { nil }
    quantity { 1 }
  end
end
