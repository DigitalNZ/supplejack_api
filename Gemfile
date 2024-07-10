# frozen_string_literal: true

source 'https://rubygems.org'

# Declare your gem's dependencies in supplejack_api.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem 'codeclimate_diff', github: 'boost/codeclimate_diff', tag: 'v0.1.10'
gem 'rsolr', '< 2.6.0' # sunspot 2.4.0 has a bug on rsolr 2.6.0
gem 'sunspot', github: 'sunspot/sunspot', tag: 'v2.4.0'

group :test do
  gem 'faker'
  gem 'generator_spec'
  gem 'json-schema'
end
