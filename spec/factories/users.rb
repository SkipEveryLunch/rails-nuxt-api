FactoryBot.define do
  factory :user do
    sequence(:name) do |n|
      "Name #{n}"
    end
    sequence(:email) do |n|
      "#{n}@test.io"
    end
  end
end
