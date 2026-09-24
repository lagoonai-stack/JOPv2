if Rails.env.test?
  require "simplecov"
  SimpleCov.start "rails" do
    add_filter "admin"
    add_filter "mailers"
    add_filter "services"
  end
end
