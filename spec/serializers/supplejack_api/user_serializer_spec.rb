require "spec_helper"

module SupplejackApi
  describe UserSerializer do
    let(:user) { User.new(name: "Fed", email: "fed@boost.com", username: "fede", authentication_token: "12345") }
    let(:serializer) { UserSerializer.new(user) }
  
    it "includes the basic user information" do
      user.stub(:id) { "abc1234567" }
      serializer.as_json.should eq({user: {id: "abc1234567", name: "Fed", email: "fed@boost.com", username: "fede", api_key: "12345"}})
    end
  
  end

end
