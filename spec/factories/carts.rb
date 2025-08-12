FactoryBot.define do
  factory :cart do
    user { nil }
    product { nil }
    product_variant { nil }
    quantity { 1 }
  end
end
