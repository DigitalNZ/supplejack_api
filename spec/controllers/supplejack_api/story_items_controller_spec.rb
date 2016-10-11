# frozen_string_literal: true
module SupplejackApi
  RSpec.describe StoryItemsController do
    routes { SupplejackApi::Engine.routes }

    let(:user) { create(:user) }
    let(:api_key) { user.api_key }
    let(:story) { create(:story) }

    describe 'GET index' do
    end

    describe 'GET show' do
    end

    describe 'POST create' do
    end

    describe 'DELETE create' do
    end

    describe 'PATCH update' do
    end

    describe 'PUT update' do
    end    
  end
end
