

require 'spec_helper'

module SupplejackApi
  describe UserSerializer do
    let(:user) { FactoryBot.create(:user) }
    let(:serialized_user) { described_class.new(user).as_json }

    it 'renders the :id' do
      expect(serialized_user).to have_key :id
    end

    it 'renders the :name' do
      expect(serialized_user).to have_key :name
    end

    it 'renders the :email' do
      expect(serialized_user).to have_key :email
    end

    it 'renders the :username' do
      expect(serialized_user).to have_key :username
    end

    it 'renders the :api_key' do
      expect(serialized_user).to have_key :api_key
    end
  end
end
