require 'spec_helper'

RSpec.describe 'Story Items Endpoints', type: :request do
  let(:admin) { create(:admin_user) }
  let(:story) { create(:story) }

  describe '#index' do
    context 'when requesting without a user_key' do
      before { get "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}" }

      it 'returns an error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => 'Mandatory parameter user_key missing' })
      end
    end

    context 'when requesting with a invalid user_key' do
      before { get "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}&user_key=fakeuserkey" }

      it 'returns an error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => 'User with provided Api Key fakeuserkey not found' })
      end
    end

    context 'when requesting with a invalid story id' do
      before { get "/v3/stories/thisstoryiddontexist/items.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}" }

      it 'returns an error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => 'Story with provided Id thisstoryiddontexist not found' })
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

  describe '#show' do
    let(:item) { story.set_items.first }

    context 'when item exists' do
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

    context 'when story dosent exist' do
      before { get "/v3/stories/thisstoryiddontexist/items/#{item.id.to_s}.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}" }

      it 'returns an error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => 'Story with provided Id thisstoryiddontexist not found' })
      end
    end

    context 'when story item dosent exist' do
      before { get "/v3/stories/#{story.id}/items/fakeitemid.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}" }

      it 'returns error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => "StoryItem with provided Id fakeitemid not found for Story with provided Story Id #{story.id}" })
      end
    end
  end

  describe '#create' do
    let(:item) { story.set_items.first }

    context 'when request is unsuccessful' do
      context 'when mandatory params are missing' do
        it 'returns error for missing items' do
          params = {}.to_query
          post "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"

          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq ({ 'errors' => 'Mandatory Parameter item missing in request' })
        end

        context 'when item is text' do
          it 'returns error for missing type & sub_type' do
            params = { item: { name: 'text' } }.to_query
            post "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"

            response_attributes = JSON.parse(response.body)

            expect(response_attributes).to eq ({ 'errors' => 'Mandatory Parameters Missing: type is missing, Mandatory Parameters Missing: sub_type is missing' })
          end

          it 'returns error for missing content & meta' do
            params = { item: { type: 'text', sub_type: 'heading' } }.to_query
            post "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"

            response_attributes = JSON.parse(response.body)

            expect(response_attributes).to eq ({ 'errors' => 'Content value is missing: content must contain value filed' })
          end

          it 'returns error for size is not valid' do
            params = { item: { type: 'text', sub_type: 'heading', content: { value: 'Heading text' }, meta: { size: 45 } } }.to_query
            post "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"

            response_attributes = JSON.parse(response.body)

            expect(response_attributes).to eq ({ 'errors' => 'Unsupported Values: size must be one of: 1, 2, 3, 4, 5, 6 in meta' })
          end
        end

        context 'when item is a embed record' do
          context 'params are right' do
            let(:record) { create(:record) }

            it 'returns success' do
              params = { item: { type: 'embed', sub_type: 'record', record_id: record.record_id, content: { id: record.record_id }, meta: { alignment: 'left' } } }.to_query
              post "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"

              response_attributes = JSON.parse(response.body)
              story.reload
              new_item = story.set_items.last
              expected_attributes = { 'id' => new_item.id.to_s, 'position' => new_item.position,
                                      'type' => "embed", 'sub_type' => 'record',
                                      'record_id' => record.record_id,
                                      'content' => {
                                        'id' =>  record.record_id, 'title' => 'Untitled',
                                        'display_collection' => nil, 'category' => [],
                                        'image_url' => nil, 'landing_url' => nil,
                                        'tags' => [], 'description' => nil,
                                        'content_partner' => [], 'creator' => [],
                                        'rights' => nil, 'contributing_partner' => [],
                                        'status' => "active"
                                      },
                                      'meta' => { 'alignment' => 'left', 'is_cover' => false } }



              expect(response_attributes).to eq expected_attributes
            end
          end

          context 'when record id is passed wrongly' do
            it 'returns error for missing record id in content' do
              params = { item: { type: 'embed', sub_type: 'record', content: { id: nil }, meta: { alignment: 'left' } } }.to_query
              post "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"

              response_attributes = JSON.parse(response.body)

              expect(response_attributes).to eq ({ 'errors' => 'Content id is missing: content must contain integer field id' })
            end

            it 'returns error for invalid id type' do
              params = { item: { type: 'embed', sub_type: 'record', content: { id: 'i100' }, meta: { alignment: 'left' } } }.to_query
              post "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"

              response_attributes = JSON.parse(response.body)

              expect(response_attributes).to eq ({ 'errors' => 'Unsupported Value: content must contain integer field id' })
            end
          end
        end
      end
    end

    context 'when adding a new heading to story' do
      let(:item) { story.set_items.first }

      it 'returns success' do
        params = { item: { type: 'text', sub_type: 'heading', content: { value: 'Heading text' }, meta: { align_mode: 0 } } }.to_query
        post "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"

        response_attributes = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(response_attributes).to include('type' => 'text', 'sub_type' => 'heading', 'content' => { 'value' => 'Heading text' }, 'meta' => { 'align_mode' => '0', 'is_cover' => false })
      end
    end

    context 'when adding rich text to story' do
      it 'returns success' do
        params = { item: { type: 'text', sub_type: 'rich-text', content: { value: '<p>Some block content here</p>' }, meta: { align_mode: 0 } } }.to_query
        post "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"

        response_attributes = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(response_attributes).to include({ 'type' => 'text', 'sub_type' => 'rich-text', 'content' => { 'value' => '<p>Some block content here</p>' } })
      end
    end

    context 'when adding record to story' do
      let(:record) { create(:record) }

      it 'returns success' do
        params = { item: { type: 'embed', sub_type: 'record', record_id: record.record_id, content: { id: record.record_id }, meta: { align_mode: 0 } } }.to_query
        post "/v3/stories/#{story.id}/items.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"

        response_attributes = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(response_attributes).to include({
          'type' => 'embed',
          'sub_type' => 'record',
          'content' => {
            'category' => [],
            'content_partner' => [],
            'contributing_partner' => [],
            'creator' => [],
            'description' => nil,
            'display_collection' => nil,
            'id' => record.record_id,
            'image_url' => nil,
            'landing_url' => nil,
            'rights' => nil,
            'status' => 'active',
            'tags' => [],
            'title' => 'Untitled'
          }
        })
      end
    end
  end

  describe '#destroy' do
    let(:item) { story.set_items.first }

    context 'when story id does not exist' do
      before { delete "/v3/stories/fakestoryid/items/#{item.id.to_s}.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}" }

      it 'returns error message' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => I18n.t('errors.story_not_found', id: 'fakestoryid') })
      end
    end

    context 'when story item dosent exist' do
      before { delete "/v3/stories/#{story.id}/items/fakeitemid.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}" }

      it 'returns error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => "StoryItem with provided Id fakeitemid not found for Story with provided Story Id #{story.id}" })
      end
    end

    context 'when story & item exists' do
      before { delete "/v3/stories/#{story.id}/items/#{item.id.to_s}.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}" }

      it 'returns 204' do
        expect(response.status).to eq 204
      end
    end
  end
end
