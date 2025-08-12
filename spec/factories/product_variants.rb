FactoryBot.define do
  factory :product_variant do
    product { nil }
    name { "MyString" }
    sku { "MyString" }
    price { "9.99" }
    stock_quantity { 1 }
    variant_attributes { "" }
  end
end
