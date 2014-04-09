module SupplejackApi
  class UserSerializer < ApplicationSerializer
    
    attributes :id, :name, :username, :email, :api_key
  end

end
