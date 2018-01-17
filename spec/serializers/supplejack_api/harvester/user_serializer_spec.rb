# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::Harvester::UserSerializer do
  let(:user) { create(:user) }
  let(:serializer) { described_class.new(user).as_json }

  describe '#attributes' do
    it 'renders the :id' do
      expect(serializer).to have_key :id
    end

    it 'renders the :username' do
      expect(serializer).to have_key :username
    end

    it 'renders the :name' do
      expect(serializer).to have_key :name
    end

    it 'renders the :authentication_token' do
      expect(serializer).to have_key :authentication_token
    end

    it 'renders the :email' do
      expect(serializer).to have_key :email
    end

    it 'renders the :role' do
      expect(serializer).to have_key :role
    end

    it 'renders the :daily_requests' do
      expect(serializer).to have_key :daily_requests
    end

    it 'renders the :monthly_requests' do
      expect(serializer).to have_key :monthly_requests
    end

    it 'renders the :max_requests' do
      expect(serializer).to have_key :max_requests
    end
  end
end
