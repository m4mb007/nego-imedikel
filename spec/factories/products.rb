FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 10..1000) }
    sku { Faker::Alphanumeric.alphanumeric(number: 10) }
    association :category
    association :user
    status { 1 }
    featured { false }
    stock_quantity { Faker::Number.between(from: 1, to: 100) }
    weight { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    dimensions { "#{Faker::Number.between(from: 10, to: 50)}x#{Faker::Number.between(from: 10, to: 50)}x#{Faker::Number.between(from: 5, to: 20)}cm" }
    brand { Faker::Company.name }
  end
end
