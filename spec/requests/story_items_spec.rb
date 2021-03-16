require 'spec_helper'

RSpec.describe 'Stories Items', type: :request do
  let(:admin) { create(:admin_user) }
  let(:story) { create(:story) }

  describe 'index' do
    context 'when requesting without a user_key' do
      before { get "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}" }

      it 'returns an error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => 'Mandatory parameter user_key missing' })
      end
    end

    context 'when requesting with a user_key' do
      before { get "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}" }

      it 'returns story items for the user key' do
        response_attributes = JSON.parse(response.body)
  
        expect(response_attributes).to eq (
          story.set_items.sort_by(&:position).map do |item|
            {
              'record_id' => item.record_id,
              'id' => item.id.to_s,
              'position' => item.position,
              'type' => item.type,
              'sub_type' => item.sub_type,
              'content' => DEFAULT_CONTENT_PRESENTER.call(item),
              'meta' => { 'size' => item.meta[:size], 'is_cover' => (item.content[:image_url] == story.cover_thumbnail) }
            }
          end
        )
      end
    end
  end

  describe 'show' do
    let(:item) { story.set_items.first }

    before { get "/v3/stories/#{story.id}/items/#{item.id.to_s}.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}" }

    it 'returns story items for the user key' do
      response_attributes = JSON.parse(response.body)

      expect(response_attributes).to eq (
        {
          'record_id' => item.record_id,
          'id' => item.id.to_s,
          'position' => item.position,
          'type' => item.type,
          'sub_type' => item.sub_type,
          'content' => DEFAULT_CONTENT_PRESENTER.call(item),
          'meta' => { 'size' => item.meta[:size], 'is_cover' => (item.content[:image_url] == story.cover_thumbnail) }
        }
      )
    end
  end

  describe 'create' do
    before do
      params = { story: { name: 'New Story Name' } }.to_query

      post "/v3/stories/#{story.id}/items/#{item.id.to_s}.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"
    end

    context 'when adding a new record to story' do
    end

    context 'when adding a new heading to story' do
    end

    context 'when adding rich text to story' do
    end
  end
end
