# frozen_string_literal: true

require 'supplejack_api/engine'
require 'pundit'

Dir["#{File.dirname(__FILE__)}/**/*.rb"].sort.each { |f| require f }

module SupplejackApi
end
