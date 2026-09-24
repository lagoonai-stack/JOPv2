# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "admin#{n}@#{Faker::Internet.domain_name}" }
    password { "AdminPassword123!" }
    password_confirmation { "AdminPassword123!" }
  end
end
