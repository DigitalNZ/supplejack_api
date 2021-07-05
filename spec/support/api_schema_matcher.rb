# frozen_string_literal: true

require 'json-schema'

RSpec::Matchers.define :match_response_schema do |schema|
  match do |json|
    schema_directory = "#{Dir.pwd}/spec/support/api/schemas"
    schema_path = "#{schema_directory}/#{schema}.json"

    errors = JSON::Validator.fully_validate(schema_path, json)

    # rubocop:disable Style/RaiseArgs, Style/SignalException, Lint/RaiseException
    fail Exception.new(errors.join(' ----- ')) unless errors.empty?
    # rubocop:enable Style/RaiseArgs, Style/SignalException, Lint/RaiseException

    true
  end
end
