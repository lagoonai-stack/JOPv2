# frozen_string_literal: true

# Planos em BRL (centavos). Limites de tokens por período de assinatura.
Rails.application.config.stripe_plans = {
  "free" => {
    name: "Free",
    price_cents: 0,
    currency: "brl",
    max_tokens_per_month: 60_000,
    description: "Plano de teste gratuito"
  },
  "starter" => {
    name: "Starter",
    price_cents: 4990,
    currency: "brl",
    max_tokens_per_month: 90_000,
    description: ""
  },
  "pro" => {
    name: "Pro",
    price_cents: 5790,
    currency: "brl",
    max_tokens_per_month: 180_000,
    description: ""
  }
}.freeze
