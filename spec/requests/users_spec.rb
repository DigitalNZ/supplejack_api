require 'spec_helper'

RSpec.describe 'Users', type: :request do
  let(:admin) { create(:admin_user) }
  let(:user) { create(:user) }

  describe 'show' do
    before { get "/v3/users/#{user.id}.json?api_key=#{admin.authentication_token}" }

    it 'returns user info' do
      response_attributes = JSON.parse(response.body)['user']

      expect(response_attributes).to eq (
        {
          'id' => user.id.to_s,
          'name' => user.name,
          'username' => user.username,
          'email' => user.email,
          'api_key' => user.authentication_token
        }
      )
    end
  end

  describe 'create' do
    before do
      params = { user: { name: 'New api user' } }

      post "/v3/users.json?api_key=#{admin.authentication_token}&#{params.to_query}"
    end

    it 'returns user info' do
      response_attributes = JSON.parse(response.body)['user']

      user = SupplejackApi::User.last

      expect(response_attributes).to eq (
        {
          'id' => user.id.to_s,
          'name' => 'New api user',
          'username' => user.username,
          'email' => user.email,
          'api_key' => user.authentication_token
        }
      )
    end
  end

  describe 'update' do
    before { put "/v3/users/#{user.id}.json?api_key=#{admin.authentication_token}&user[name]=NewName" }

    it 'returns user info of updated user' do
      response_attributes = JSON.parse(response.body)['user']

      expect(response_attributes).to eq (
        {
          'id' => user.id.to_s,
          'name' => 'NewName',
          'username' => user.username,
          'email' => user.email,
          'api_key' => user.authentication_token
        }
      )
    end
  end

  describe 'delete' do
    before { delete "/v3/users/#{user.id}.json?api_key=#{admin.authentication_token}" }

    it 'returns user info' do
      response_attributes = JSON.parse(response.body)['user']

      expect(response_attributes).to eq (
        {
          'id' => user.id.to_s,
          'name' => user.name,
          'username' => user.username,
          'email' => user.email,
          'api_key' => user.authentication_token
        }
      )
    end
  end
end

