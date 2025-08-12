FactoryBot.define do
  factory :product do
    name { "MyString" }
    description { "MyText" }
    price { "9.99" }
    sku { "MyString" }
    category { nil }
    user { nil }
    status { 1 }
    featured { false }
    stock_quantity { 1 }
    weight { "9.99" }
    dimensions { "MyString" }
    brand { "MyString" }
  end
end
