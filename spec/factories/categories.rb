FactoryBot.define do
  factory :category do
    name { Faker::Commerce.department }
    description { Faker::Lorem.paragraph }
    slug { Faker::Internet.slug }
    parent { nil }
    position { Faker::Number.between(from: 1, to: 10) }
    status { 1 }
  end
end
