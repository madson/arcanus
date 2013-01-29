FactoryGirl.define do
  factory :entry do
    name "Teste"
    content "foobarbaz"
    password "12345"
    author
  end
end