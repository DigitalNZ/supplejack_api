require 'voight_kampff'

# Reopen the Rack::Request class to add bot detection methods

ActionController::TestRequest.class_eval do
  include VoightKampff::Methods
end

ActionDispatch::Request.class_eval do
  include VoightKampff::Methods
end
