source 'https://rubygems.org'

gem 'yard'
gem 'rake'

group :test do
  gem 'rspec',       '~> 2.14.1'
  # gem 'rspec-mocks', '~> 2.14.4'
  gem 'vcr'
  gem 'webmock', '~> 3.0.1'
  gem 'simplecov',   '~> 0.8.1', :require => false
  gem 'growl'
  gem 'growl-rspec'
end

group :development do
  gem 'guard-rspec'
end

group :development, :test do
  gem 'pry-remote'
  gem 'pry-byebug'
end

gemspec
