# frozen_string_literal: true

Rails.configuration.stripe = {
  publishable_key: ENV.fetch("STRIPE_PUBLISHABLE_KEY", nil),
  secret_key: ENV.fetch("STRIPE_SECRET_KEY", nil),
  webhook_secret: ENV.fetch("STRIPE_WEBHOOK_SECRET", nil)
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
Stripe.log_level = Rails.env.development? ? Stripe::LEVEL_DEBUG : Stripe::LEVEL_INFO
Stripe.max_network_retries = 3
