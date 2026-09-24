# Load fixtures and provide helpers to access them (avoid Minitest-style users(:one) in RSpec).
# Uses ensure_app_fixtures_loaded (not load_fixtures) so we don't override ActiveRecord::TestFixtures#load_fixtures.
module FixtureHelpers
  FIXTURE_PATH = Rails.root.join("spec/fixtures").freeze

  def ensure_app_fixtures_loaded
    return if @app_fixtures_loaded

    ActiveRecord::FixtureSet.create_fixtures(FIXTURE_PATH, %w[users admin_users])
    @app_fixtures_loaded = true
  end

  def test_user
    ensure_app_fixtures_loaded
    User.find_by!(email: "user@example.com")
  end

  def admin_user_one
    ensure_app_fixtures_loaded
    AdminUser.find_by!(email: "admin@example.com")
  end
end

RSpec.configure do |config|
  config.include FixtureHelpers, type: :request
  config.include FixtureHelpers, type: :model
  # Fixtures are loaded on demand when test_user or admin_user_one is first used (no global before).
end
