source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Tailwind CSS
gem "tailwindcss-rails"
# Authentication and Authorization
gem "devise", "~> 4.9"
gem "omniauth-google-oauth2", "~> 1.1"
gem "omniauth-facebook", "~> 9.0"
gem "omniauth-apple", "~> 1.0"
gem "pundit", "~> 2.3"

# Payment Processing
gem "stripe", "~> 12.0"
gem "pay", "~> 11.2"

# File Upload and Image Processing
gem "image_processing", "~> 1.2"
gem "aws-sdk-s3", require: false

# Background Jobs and Caching
gem "sidekiq", "~> 7.0"
gem "redis", "~> 5.0"

# API and JSON
gem "rack-cors", "~> 2.0"

# Search and Filtering
gem "ransack", "~> 4.1"
gem "elasticsearch-rails", "~> 7.0"

# Notifications and Communication
gem "twilio-ruby", "~> 6.0"
gem "sendgrid-ruby", "~> 6.0"
gem "fcm", "~> 1.0"

# Utilities
gem "bcrypt", "~> 3.1.7"
gem "kaminari", "~> 1.2"
gem "friendly_id", "~> 5.4"
gem "acts_as_list", "~> 1.1"
gem "acts_as_paranoid", "~> 0.7"
gem "money-rails", "~> 1.15"
gem "geocoder", "~> 1.8"
gem "validates_zipcode", "~> 0.0.6"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
  
  # Testing
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  
  # Better error pages
  gem "better_errors", "~> 2.10"
  gem "binding_of_caller", "~> 1.0"
  
  # Database management
  # gem "annotate", "~> 3.2" # Temporarily disabled for Rails 8 compatibility
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
