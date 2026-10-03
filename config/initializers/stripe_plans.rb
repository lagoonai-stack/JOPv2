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
  },
  # Plano interno: atribuído manualmente (rake users:assign_unlimited_plan EMAIL=...).
  # Nunca aparece no pricing nem no checkout — ver :internal.
  "unlimited" => {
    name: "Unlimited",
    price_cents: 0,
    currency: "brl",
    max_tokens_per_month: 1_000_000_000_000,
    description: "Plano interno sem limite de tokens",
    internal: true
  }
}.freeze
