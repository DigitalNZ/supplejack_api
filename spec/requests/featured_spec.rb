# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Featured Endpoints', type: :request do
  let(:admin) { create(:admin_user) }
  let(:story) { create(:story_with_dnz_story_items) }

  describe '#index' do
    context 'when featured stories dosent exist' do
      before { get "/v3/stories/featured.json?api_key=#{admin.authentication_token}" }

      it 'returns stories for the user key' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq([])
      end
    end

    context 'when featured stories exist' do
      before do
        story.update_attribute(:featured, true)

        get "/v3/stories/featured.json?api_key=#{admin.authentication_token}"
      end

      it 'returns stories for the user key' do
        response_attributes = JSON.parse(response.body)
        record_ids = story.set_items.map { |item| { 'record_id' => item.record_id, 'story_item_id' => item.id.to_s } }

        expect(response_attributes).to eq(
          [{
            'approved' => story.approved,
            'category' => 'C',
            'copyright' => story.copyright,
            'cover_thumbnail' => story.cover_thumbnail,
            'creator' => story.user.name,
            'description' => story.description,
            'featured' => true,
            'featured_at' => story.featured_at,
            'id' => story.id.to_s,
            'name' => story.name,
            'number_of_items' => story.set_items.reject { |item| item.type == 'text' }.count,
            'privacy' => 'public',
            'record_ids' => record_ids,
            'subjects' => story.subjects,
            'tags' => story.tags,
            'updated_at' => JSON.parse(story.updated_at.to_json),
            'state' => story.state,
            'user_id' => story.user.id.to_s
          }]
        )
      end
    end
  end
end
