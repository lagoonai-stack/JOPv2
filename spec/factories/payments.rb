# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    association :user
    plan { "starter" }
    amount_cents { 4990 }
    currency { "brl" }
    status { "completed" }
    sequence(:stripe_session_id) { |n| "cs_#{n}_#{SecureRandom.hex(4)}" }
  end
end
