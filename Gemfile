source "https://rubygems.org"

gem "rails", "~> 8.1.2"

gem "activeadmin"
gem "chartkick"
gem "devise", "< 5"
gem "dotenv-rails"
gem "groupdate"
gem "haml-rails"
gem "importmap-rails"
gem "jbuilder"
gem "openai", "~> 0.90.0"
gem "pg", "~> 1.1"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rack-attack"
gem "rack-cors"
gem "resend"
gem "stimulus-rails"
gem "stripe", "~> 12.0"
gem "turbo-rails"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

group :development, :test do
  gem "faker"
  gem "pry-byebug"
  gem "rspec-rails", "~> 7.0"
end

group :development do
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "letter_opener"
  gem "letter_opener_web", "~> 3.0"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "factory_bot_rails", "~> 6.4"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "vcr"
  gem "webmock"
end
