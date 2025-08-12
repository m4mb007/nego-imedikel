FactoryBot.define do
  factory :order do
    user { nil }
    store { nil }
    total_amount { "9.99" }
    status { 1 }
    payment_status { 1 }
    shipping_address { "MyText" }
    billing_address { "MyText" }
    tracking_number { "MyString" }
  end
end
