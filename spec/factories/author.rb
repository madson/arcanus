FactoryGirl.define do
  factory :author do
    sequence(:name) { |n| "John Smith #{n}" }
    password "123456"
  end
end