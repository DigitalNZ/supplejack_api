# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Stories Endpoints', type: :request do
  let(:admin)   { create(:admin_user) }
  let(:story)   { create(:story) }
  let(:api_key) { admin.authentication_token }

  describe '#index' do
    context 'when requesting without a user_key' do
      before { get "/v3/stories.json?api_key=#{api_key}" }

      it 'returns an error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq({ 'errors' => I18n.t('errors.user_key_missing') })
      end
    end

    context 'when requesting with wrong user_key' do
      before { get "/v3/stories.json?api_key=#{api_key}&user_key=thisisafakekey" }

      it 'returns error message' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq({ 'errors' => I18n.t('errors.user_not_found', key: 'thisisafakekey') })
      end
    end

    context 'when requesting with a user_key of the story user' do
      context 'when requested without slim flag' do
        before { get "/v3/stories.json?api_key=#{api_key}&user_key=#{story.user.api_key}" }

        it 'returns stories for the user key' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq(
            [
              { 'name' => story.name,
                'description' => story.description,
                'privacy' => story.privacy,
                'copyright' => 0,
                'featured' => story.featured,
                'featured_at' => story.featured_at,
                'approved' => story.approved,
                'tags' => story.tags,
                'subjects' => story.subjects,
                'updated_at' => JSON.parse(story.updated_at.to_json),
                'cover_thumbnail' => story.cover_thumbnail,
                'id' => story.id.to_s,
                'number_of_items' => story.set_items.reject { |item| item.type == 'text' }.count,
                'creator' => story.user.name,
                'category' => 'Other',
                'record_ids' => story.set_items.sort_by(&:position).map do |item|
                                  { 'record_id' => item.record_id, 'story_item_id' => item._id.to_s }
                                end }
            ]
          )
        end
      end

      context 'when requested with slim flag false' do
        before do
          get "/v3/stories.json?api_key=#{api_key}&user_key=#{story.user.api_key}&slim=false"
        end

        it 'returns stories for the user key' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq(
            [
              { 'name' => story.name,
                'description' => story.description,
                'privacy' => story.privacy,
                'copyright' => 0,
                'featured' => story.featured,
                'featured_at' => story.featured_at,
                'approved' => story.approved,
                'tags' => story.tags,
                'subjects' => story.subjects,
                'updated_at' => JSON.parse(story.updated_at.to_json),
                'cover_thumbnail' => story.cover_thumbnail,
                'id' => story.id.to_s,
                'number_of_items' => story.set_items.reject { |item| item.type == 'text' }.count,
                'creator' => story.user.name,
                'category' => 'Other',
                'contents' => story.set_items.map do |content|
                  { 'record_id' => content.record_id,
                    'id' => content.id.to_s,
                    'position' => content.position,
                    'type' => content.type,
                    'sub_type' => content.sub_type,
                    'content' => { 'value' => content.content[:value],
                                   'image_url' => content.content[:image_url],
                                   'display_collection' => content.content[:display_collection],
                                   'category' => content.content[:category] },
                    'meta' => { 'size' => content.meta[:size], 'is_cover' => false } }
                end }
            ]
          )
        end
      end
    end
  end

  describe '#show' do
    context 'when story id exists' do
      before { get "/v3/stories/#{story.id}.json?api_key=#{api_key}" }

      it 'returns story' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq(
          { 'name' => story.name,
            'description' => story.description,
            'privacy' => story.privacy,
            'copyright' => 0,
            'featured' => story.featured,
            'featured_at' => story.featured_at,
            'approved' => story.approved,
            'tags' => story.tags,
            'subjects' => story.subjects,
            'updated_at' => JSON.parse(story.updated_at.to_json),
            'cover_thumbnail' => story.cover_thumbnail,
            'id' => story.id.to_s,
            'number_of_items' => story.set_items.reject { |item| item.type == 'text' }.count,
            'creator' => story.user.name,
            'category' => 'Other',
            'contents' => story.set_items.sort_by(&:position).map do |item|
                            {
                              'record_id' => item.record_id,
                              'id' => item.id.to_s,
                              'position' => item.position,
                              'type' => item.type,
                              'sub_type' => item.sub_type,
                              'content' => DEFAULT_CONTENT_PRESENTER.call(item),
                              'meta' => {
                                'size' => item.meta[:size],
                                'is_cover' => (item.content[:image_url] == story.cover_thumbnail)
                              }
                            }
                          end }
        )
      end
    end

    context 'when story id dosent exists' do
      before { get "/v3/stories/fakestoryid.json?api_key=#{api_key}" }

      it 'returns error message' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq({ 'errors' => I18n.t('errors.story_not_found', id: 'fakestoryid') })
      end
    end

    context 'when story is private' do
      let(:story) { create(:story, privacy: 'private') }

      context 'when user_key belongs to the story owner' do
        before do
          get "/v3/stories/#{story.id}.json?api_key=#{api_key}&user_key=#{story.user.api_key}"
        end

        it 'returns story' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq(
            { 'name' => story.name,
              'description' => story.description,
              'privacy' => story.privacy,
              'copyright' => 0,
              'featured' => story.featured,
              'featured_at' => story.featured_at,
              'approved' => story.approved,
              'tags' => story.tags,
              'subjects' => story.subjects,
              'updated_at' => JSON.parse(story.updated_at.to_json),
              'cover_thumbnail' => story.cover_thumbnail,
              'id' => story.id.to_s,
              'number_of_items' => story.set_items.reject { |item| item.type == 'text' }.count,
              'creator' => story.user.name,
              'category' => 'Other',
              'contents' => story.set_items.sort_by(&:position).map do |item|
                              {
                                'record_id' => item.record_id,
                                'id' => item.id.to_s,
                                'position' => item.position,
                                'type' => item.type,
                                'sub_type' => item.sub_type,
                                'content' => DEFAULT_CONTENT_PRESENTER.call(item),
                                'meta' => {
                                  'size' => item.meta[:size],
                                  'is_cover' => (item.content[:image_url] == story.cover_thumbnail)
                                }
                              }
                            end }
          )
        end
      end

      context 'when user_key does not belongs to the story owner' do
        before { get "/v3/stories/#{story.id}.json?api_key=#{api_key}&user_key=fakestoryuserkey" }

        it 'returns error message' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes)
            .to eq({ 'errors' => I18n.t('errors.user_not_authorized_for_story', id: story.id.to_s) })
        end
      end
    end
  end

  describe '#create' do
    context 'successful post' do
      before do
        params = { story: { name: 'New Story Name',
                            description: nil,
                            privacy: nil,
                            copyright: nil,
                            tags: nil,
                            subjects: nil } }.to_query

        post "/v3/stories.json?api_key=#{api_key}&user_key=#{story.user.api_key}&#{params}"
      end

      it 'returns attributes for the story created' do
        story = SupplejackApi::UserSet.last
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq(
          { 'name' => 'New Story Name',
            'description' => story.description,
            'privacy' => story.privacy,
            'copyright' => 0,
            'featured' => story.featured,
            'featured_at' => story.featured_at,
            'approved' => story.approved,
            'tags' => story.tags,
            'subjects' => story.subjects,
            'updated_at' => JSON.parse(story.updated_at.to_json),
            'cover_thumbnail' => story.cover_thumbnail,
            'id' => story.id.to_s,
            'number_of_items' => story.set_items.reject { |item| item.type == 'text' }.count,
            'creator' => story.user.name,
            'category' => 'Other',
            'contents' => [] }
        )
      end
    end

    context 'failures' do
      context 'when user not found' do
        before do
          params = { story: { name: 'New Story Name' } }.to_query

          post "/v3/stories.json?api_key=#{api_key}&user_key=fakeapiuserkey&#{params}"
        end

        it 'returns user not found error' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq({ 'errors' => I18n.t('errors.user_not_found', key: 'fakeapiuserkey') })
        end
      end

      context 'when story name is empty' do
        before do
          params = { story: { privacy: 'public' } }.to_query

          post "/v3/stories.json?api_key=#{api_key}&user_key=#{story.user.api_key}&#{params}"
        end

        it 'returns mandatory param error' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq({ 'errors' => {"name"=>["Name field can't be blank."]} })
        end
      end
    end
  end

  describe '#update' do
    context 'when story id exists' do
      context 'when user key does not belong to story' do
        let(:user) { create(:user) }

        before do
          params = { story: { name: 'Updated Story Name' } }.to_query

          patch "/v3/stories/#{story.id}.json?api_key=#{api_key}&user_key=#{user.api_key}&#{params}"
        end

        it 'returns error message' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq({ 'errors' => I18n.t('errors.user_not_authorized_for_story') })
        end
      end

      context 'when updating top level story fields' do
        before do
          params = { story: { name: 'Updated Story Name', tags: ['tag1'] } }.to_query

          patch "/v3/stories/#{story.id}.json?api_key=#{api_key}&user_key=#{story.user.api_key}&#{params}"
        end

        it 'returns user info of updated story' do
          response_attributes = JSON.parse(response.body)

          story.reload

          expect(response_attributes).to eq(
            { 'name' => 'Updated Story Name',
              'description' => story.description,
              'privacy' => story.privacy,
              'copyright' => 0,
              'featured' => story.featured,
              'featured_at' => story.featured_at,
              'approved' => story.approved,
              'tags' => ['tag1'],
              'subjects' => story.subjects,
              'updated_at' => JSON.parse(story.updated_at.to_json),
              'cover_thumbnail' => story.cover_thumbnail,
              'id' => story.id.to_s,
              'number_of_items' => story.set_items.reject { |item| item.type == 'text' }.count,
              'creator' => story.user.name,
              'category' => 'Other',
              'contents' => story.set_items.sort_by(&:position).map do |item|
                              {
                                'record_id' => item.record_id,
                                'id' => item.id.to_s,
                                'position' => item.position,
                                'type' => item.type,
                                'sub_type' => item.sub_type,
                                'content' => DEFAULT_CONTENT_PRESENTER.call(item),
                                'meta' => {
                                  'size' => item.meta[:size],
                                  'is_cover' => (item.content[:image_url] == story.cover_thumbnail)
                                }
                              }
                            end }
          )
        end
      end

      context 'when adding a content' do
        before do
          params = {
            story: {
              content: { position: 5, type: 'text', sub_type: 'heading', content: 'Heading Text' }
            }
          }.to_query

          patch "/v3/stories/#{story.id}.json?api_key=#{api_key}&user_key=#{story.user.api_key}&#{params}"
        end

        it 'returns user info of updated story' do
          response_attributes = JSON.parse(response.body)

          story.reload

          expect(response_attributes).to eq(
            { 'name' => story.name,
              'description' => story.description,
              'privacy' => story.privacy,
              'copyright' => 0,
              'featured' => story.featured,
              'featured_at' => story.featured_at,
              'approved' => story.approved,
              'tags' => story.tags,
              'subjects' => story.subjects,
              'updated_at' => JSON.parse(story.updated_at.to_json),
              'cover_thumbnail' => story.cover_thumbnail,
              'id' => story.id.to_s,
              'number_of_items' => story.set_items.reject { |item| item.type == 'text' }.count,
              'creator' => story.user.name,
              'category' => 'Other',
              'contents' => story.set_items.sort_by(&:position).map do |item|
                {
                  'record_id' => item.record_id,
                  'id' => item.id.to_s,
                  'position' => item.position,
                  'type' => item.type,
                  'sub_type' => item.sub_type,
                  'content' => DEFAULT_CONTENT_PRESENTER.call(item),
                  'meta' => { 'size' => item.meta[:size],
                              'is_cover' => (item.content[:image_url] == story.cover_thumbnail) }
                }
              end }
          )
        end
      end
    end

    context 'when story id does not exist' do
      before do
        params = { story: { name: 'Updated Story Name' } }.to_query

        patch "/v3/stories/fakestoryid.json?api_key=#{api_key}&user_key=#{story.user.api_key}&#{params}"
      end

      it 'returns error message' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq({ 'errors' => I18n.t('errors.story_not_found', id: 'fakestoryid') })
      end
    end
  end

  describe '#destroy' do
    context 'when story id does not exist' do
      before do
        delete "/v3/stories/fakestoryid.json?api_key=#{api_key}&user_key=#{story.user.api_key}"
      end

      it 'returns error message' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq({ 'errors' => I18n.t('errors.story_not_found', id: 'fakestoryid') })
      end
    end

    context 'when story id exists' do
      before do
        delete "/v3/stories/#{story.id}.json?api_key=#{api_key}&user_key=#{story.user.api_key}"
      end

      it 'returns 204' do
        expect(response.status).to eq 204
      end
    end

    context 'when user of the api_key is an admin' do
      before do
        delete "/v3/stories/#{story.id}.json?api_key=#{api_key}&user_key=#{story.user.api_key}"
      end

      it 'returns 204' do
        expect(response.status).to eq 204
      end
    end

    # should be fixed
    context 'when user of the api_key is not an admin' do
      let(:user) { create(:user) }

      before do
        delete "/v3/stories/#{story.id}.json?api_key=#{user.authentication_token}&user_key=#{story.user.api_key}"
      end

      xit 'returns 401' do
        expect(response.status).to eq 401
      end
    end
  end

  describe '#admin_index' do
    context 'when requesting without a api_key' do
      before { get "/v3/users/#{story.user.api_key}/stories.json" }

      it 'returns an error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq({ 'errors' => 'Please provide a API Key' })
      end
    end

    context 'when requesting with wrong api_key' do
      before { get "/v3/users/#{story.user.api_key}/stories.json?api_key=thisisafakekey" }

      it 'returns error message' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq({ 'errors' => 'Invalid API Key' })
      end
    end

    context 'when requesting with api_key of a non admin user' do
      before { get "/v3/users/#{story.user.api_key}/stories.json?api_key=#{story.user.api_key}" }

      it 'returns error message' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq({ 'errors' => 'You need Administrator privileges to perform this request' })
      end
    end

    context 'when requesting invalid user_id BUT user id is their api key :(' do
      before { get "/v3/users/thisisafakekey/stories.json?api_key=#{api_key}" }

      it 'returns error message' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq({ 'errors' => I18n.t('errors.user_with_id_not_found', id: 'thisisafakekey') })
      end
    end

    context 'when requesting with a user_key of the story user' do
      context 'when requested without slim flag' do
        before { get "/v3/users/#{story.user.api_key}/stories.json?api_key=#{api_key}" }

        it 'returns stories for the user key' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq(
            [
              { 'name' => story.name,
                'description' => story.description,
                'privacy' => story.privacy,
                'copyright' => 0,
                'featured' => story.featured,
                'featured_at' => story.featured_at,
                'approved' => story.approved,
                'tags' => story.tags,
                'subjects' => story.subjects,
                'updated_at' => JSON.parse(story.updated_at.to_json),
                'cover_thumbnail' => story.cover_thumbnail,
                'id' => story.id.to_s,
                'number_of_items' => story.set_items.reject { |item| item.type == 'text' }.count,
                'creator' => story.user.name,
                'category' => 'Other',
                'record_ids' => story.set_items.sort_by(&:position).map do |item|
                                  { 'record_id' => item.record_id, 'story_item_id' => item._id.to_s }
                                end }
            ]
          )
        end
      end
    end
  end

  describe '#reposition_items' do
    let(:story_with_items) do
      create(:story,
             set_items: [create(:embed_dnz_item, title: 'first', position: 1),
                         create(:embed_dnz_item, title: 'middle', position: 2)])
    end

    context 'when all items are repositioned' do
      before do
        items = story_with_items.set_items

        params = {
          items: [{ id: items[0].id, position: 2 }, { id: items[1].id, position: 1 }]
        }.to_query

        post "/v3/stories/#{story_with_items.id}/reposition_items.json?api_key=#{api_key}&user_key=#{story.user.api_key}&#{params}"
      end

      it 'returns status ok' do
        expect(response).to have_http_status :ok
      end
    end

    context 'when not all items are repositioned' do
      before do
        params = { items: [{ id: story_with_items.set_items.first.id, position: 2 }] }.to_query

        post "/v3/stories/#{story_with_items.id}/reposition_items.json?api_key=#{api_key}&user_key=#{story.user.api_key}&#{params}"
      end

      it 'returns status ok' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq({ 'errors' => I18n.t('errors.reposition_error') })
      end
    end
  end
end
