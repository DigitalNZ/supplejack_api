# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe UserSerializer do
    let(:user) { create(:user) }
    let(:serialized_user) { described_class.new(user).as_json }

    it 'has :id' do
      expect(serialized_user[:id]).to eq user.id
    end

    it 'has :name' do
      expect(serialized_user[:name]).to eq user.name
    end

    it 'has :email' do
      expect(serialized_user[:email]).to eq user.email
    end

    it 'has :username' do
      expect(serialized_user[:username]).to eq user.username
    end

    it 'has :api_key' do
      expect(serialized_user[:api_key]).to eq user.api_key
    end
  end
end
