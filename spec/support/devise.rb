# Devise test helpers for request specs (sign_in, sign_out, etc.)
RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end
