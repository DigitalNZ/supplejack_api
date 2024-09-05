# frozen_string_literal: true

source 'https://rubygems.org'

# Declare your gem's dependencies in supplejack_api.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem 'codeclimate_diff', github: 'boost/codeclimate_diff', tag: 'v0.1.10'

# we can't add a github repository to the gemspec
# I'm waiting to know why we use the github version instead of the tag
gem 'rsolr', '< 2.6.0' # sunspot 2.4.0 has a bug on rsolr 2.6.0
gem 'sunspot', github: 'DigitalNZ/sunspot', branch: 'pm/witout-with-fulltext', glob: 'sunspot/*.gemspec'
gem 'sunspot_rails', github: 'DigitalNZ/sunspot', branch: 'pm/witout-with-fulltext', glob: 'sunspot_rails/*.gemspec'
# gem 'sunspot', path: '~/Dev/sunspot/sunspot'

group :test do
  gem 'faker'
  gem 'generator_spec'
  gem 'json-schema'
end
