FactoryBot.define do
  factory :notification do
    user { nil }
    title { "MyString" }
    message { "MyText" }
    notification_type { 1 }
    read_at { "2025-08-12 12:20:32" }
    data { "" }
  end
end
