FactoryBot.define do
  factory :address do
    user { nil }
    label { "MyString" }
    recipient_name { "MyString" }
    phone { "MyString" }
    address_line1 { "MyString" }
    address_line2 { "MyString" }
    city { "MyString" }
    state { "MyString" }
    postal_code { "MyString" }
    country { "MyString" }
    is_default { false }
  end
end
