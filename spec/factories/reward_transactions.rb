FactoryBot.define do
  factory :reward_transaction do
    reward_wallet { nil }
    transaction_type { "MyString" }
    amount { 1 }
    description { "MyText" }
    order { nil }
  end
end
