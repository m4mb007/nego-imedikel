FactoryBot.define do
  factory :category do
    name { "MyString" }
    description { "MyText" }
    slug { "MyString" }
    parent { nil }
    position { 1 }
    status { 1 }
  end
end
