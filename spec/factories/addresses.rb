FactoryBot.define do
  factory :address do
    association :user
    label { Faker::Address.community }
    recipient_name { Faker::Name.name }
    phone { Faker::PhoneNumber.phone_number }
    address_line1 { Faker::Address.street_address }
    address_line2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    postal_code { Faker::Address.zip_code }
    country { Faker::Address.country }
    is_default { false }
  end
end
