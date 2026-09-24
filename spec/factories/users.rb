# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user_#{n}_#{Faker::Alphanumeric.unique.alphanumeric(number: 8).downcase}" }
    sequence(:email) { |_n| Faker::Internet.unique.email }
    password { "Password123456!" }
    password_confirmation { "Password123456!" }
    confirmed_at { Time.current }

    trait :with_subscription do
      subscription_plan { "starter" }
      subscription_period_started_at { 1.day.ago }
      subscription_period_ends_at { 1.month.from_now }
    end

    trait :pro do
      subscription_plan { "pro" }
      subscription_period_started_at { 1.day.ago }
      subscription_period_ends_at { 1.month.from_now }
    end

    trait :expired_subscription do
      subscription_plan { "starter" }
      subscription_period_started_at { 2.months.ago }
      subscription_period_ends_at { 1.day.ago }
    end
  end
end
