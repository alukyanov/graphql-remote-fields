source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in graphql-remote-fields.gemspec
gemspec

gem 'rake'

group :development do
  gem 'byebug', platform: :ruby
  gem 'rubocop', '0.56.0'
end

group :test do
  gem 'graphql'
  gem 'graphql-errors'
  gem 'rack-parser'
  gem 'rack-test'
  gem 'rspec'
  gem 'rspec-mocks'
  gem 'sinatra'
  gem 'vcr'
  gem 'webmock'
end