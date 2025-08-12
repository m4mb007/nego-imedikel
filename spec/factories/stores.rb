FactoryBot.define do
  factory :store do
    user { nil }
    name { "MyString" }
    description { "MyText" }
    logo { nil }
    banner { nil }
    address { "MyText" }
    phone { "MyString" }
    email { "MyString" }
    website { "MyString" }
    status { 1 }
    verified_at { "2025-08-12 12:19:34" }
  end
end
