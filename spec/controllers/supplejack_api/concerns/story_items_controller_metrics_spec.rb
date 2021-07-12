# frozen_string_literal: true

require 'spec_helper'

describe ApplicationController, type: :controller do
  controller do
    include SupplejackApi::Concerns::StoryItemsControllerMetrics

    def create
      response = {
        record_id: 1001,
        content: {
          display_collection: 'Test Collection'
        }
      }

      render json: response.to_json, status: :ok
    end
  end

  let!(:story) { create(:story) }

  describe '#create' do
    before { post :create, params: { id: 1 } }

    it 'creates a added_to_user_stories SupplejackApi::RequestMetric' do
      expect(SupplejackApi::RequestMetric.count).to eq 1
      expect(SupplejackApi::RequestMetric.first.metric).to eq 'added_to_user_stories'
    end

    it 'created SupplejackApi::RequestMetric has record_id & collection name' do
      expect(SupplejackApi::RequestMetric.first.records.first.values).to include 1001
      expect(SupplejackApi::RequestMetric.first.records.first.values).to include 'Test Collection'
    end
  end
end
