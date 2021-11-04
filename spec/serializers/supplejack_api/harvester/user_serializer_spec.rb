# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::Harvester::UserSerializer do
  let(:user) { create(:user) }
  let(:serializer) { described_class.new(user).as_json }

  describe '#attributes' do
    it 'has :id' do
      expect(serializer[:id]).to eq user.id
    end

    it 'has :username' do
      expect(serializer[:username]).to eq user.username
    end

    it 'has :name' do
      expect(serializer[:name]).to eq user.name
    end

    it 'has :authentication_token' do
      expect(serializer[:authentication_token]).to eq user.authentication_token
    end

    it 'has :email' do
      expect(serializer[:email]).to eq user.email
    end

    it 'has :role' do
      expect(serializer[:role]).to eq user.role
    end

    it 'has :daily_requests' do
      expect(serializer[:daily_requests]).to eq user.daily_requests
    end

    it 'has :monthly_requests' do
      expect(serializer[:monthly_requests]).to eq user.monthly_requests
    end

    it 'has :max_requests' do
      expect(serializer[:max_requests]).to eq user.max_requests
    end
  end
end
