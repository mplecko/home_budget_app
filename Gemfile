source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.8", ">= 7.0.8.4"

# Bundler
gem 'bundler', '~> 2.5', '>= 2.5.19'

# ppostgreSQL as the database for Active Record
gem 'pg', '~> 1.5', '>= 1.5.6'

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Devise and JWT authentication
gem 'devise'
gem 'devise-jwt'

# Serialization
gem 'active_model_serializers', '~> 0.10.0'
gem 'jsonapi-serializer'

# sidekiq for background jobs
gem 'sidekiq'
gem 'sidekiq-cron'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"

# Swagger API documentation
gem 'rswag'
gem 'rswag-api'
gem 'rswag-specs'
gem 'rswag-ui'

# Rspec, faker and FactoryBot gems
gem 'factory_bot_rails'
gem 'faker'
gem 'rspec-rails'
# Gem which provides the have_many matcher with options like dependent: :destroy
gem 'shoulda-matchers'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
