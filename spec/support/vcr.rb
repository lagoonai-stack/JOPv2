# frozen_string_literal: true

require "vcr"

# Filter sensitive data from cassettes to avoid leaking tokens/auth
SENSITIVE_HEADERS = %w[
  authorization
  x-api-key
  api-key
  x-auth-token
  bearer
  stripe-signature
].freeze

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: %i[method uri body]
  }

  # Hide auth and tokens in recorded requests/responses
  config.filter_sensitive_data("<STRIPE_SECRET_KEY>") { ENV.fetch("STRIPE_SECRET_KEY", nil) }
  config.filter_sensitive_data("<STRIPE_WEBHOOK_SECRET>") { ENV.fetch("STRIPE_WEBHOOK_SECRET", nil) }
  config.filter_sensitive_data("<OPENAI_API_KEY>") { ENV.fetch("OPENAI_API_KEY", nil) }

  config.before_record do |interaction|
    SENSITIVE_HEADERS.each do |header|
      interaction.request.headers[header] = ["<REDACTED>"] if interaction.request.headers[header]
      interaction.response.headers[header] = ["<REDACTED>"] if interaction.response&.headers&.[](header)
    end
  end
end
