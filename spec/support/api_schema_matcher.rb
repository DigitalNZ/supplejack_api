require 'json-schema'

RSpec::Matchers.define :match_response_schema do |schema|
  match do |json|
    schema_directory = "#{Dir.pwd}/spec/support/api/schemas"
    schema_path = "#{schema_directory}/#{schema}.json"

    errors = JSON::Validator.fully_validate(schema_path, json)

    fail Exception.new(errors.join(' ----- ')) unless errors.empty?

    true
  end
end
