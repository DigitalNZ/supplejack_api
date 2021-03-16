require 'spec_helper'

RSpec.describe 'Story Endpoint', type: :request do
  let(:admin) { create(:admin_user) }
  let(:story) { create(:story) }

  describe '#index' do
    context 'when requesting without a user_key' do
      before { get "/v3/stories.json?api_key=#{admin.authentication_token}" }

      it 'returns an error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => 'Mandatory parameter user_key missing' })
      end
    end

    context 'when requesting with wrong user_key' do
      before { get "/v3/stories.json?api_key=#{admin.authentication_token}&user_key=thisisafakekey" }

      it 'returns error message' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => 'User with provided Api Key thisisafakekey not found' })
      end
    end

    context 'when requesting with a user_key of the story user' do
      context 'when requested without slim flag' do
        before { get "/v3/stories.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}" }

        it 'returns stories for the user key' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq (
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
                'number_of_items'=> story.set_items.to_a.count { |item| item.type != 'text' },
                'creator' => story.user.name,
                'category' => 'Other',
                'record_ids'=> story.set_items.sort_by(&:position).map do |item|
                                 { 'record_id' => item.record_id, 'story_item_id' => item._id.to_s }
                               end
              }
            ]
          )
        end
      end

      context 'when requested with slim flag false' do
        before { get "/v3/stories.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&slim=false" }

        it 'returns stories for the user key' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq (
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
                'number_of_items'=> story.set_items.to_a.count { |item| item.type != 'text' },
                'creator' => story.user.name,
                'category' => 'Other',
                'contents' => story.set_items.map do |content|
                  { 'record_id' => content.record_id,
                    'id' => content.id.to_s,
                    'position' => content.position,
                    'type' => content.type,
                    'sub_type' => content.sub_type,
                    'content' => {'value' => content.content[:value],
                                  'image_url' => content.content[:image_url],
                                  'display_collection' => content.content[:display_collection],
                                  'category' => content.content[:category] },
                    'meta' => {'size' => content.meta[:size], 'is_cover' => false } }
                end
              }
            ]
          )
        end
      end
    end
  end

  describe '#show' do
    context 'when story id exists' do
      before { get "/v3/stories/#{story.id.to_s}.json?api_key=#{admin.authentication_token}" }

      it 'returns story' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq (
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
            'number_of_items'=> story.set_items.to_a.count { |item| item.type != 'text' },
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
                              'meta' => { 'size' => item.meta[:size], 'is_cover' => (item.content[:image_url] == story.cover_thumbnail) }
                            }
                          end
          }
        )
      end
    end

    context 'when story id dosent exists' do
      before { get "/v3/stories/fakestoryid.json?api_key=#{admin.authentication_token}" }
    
      it 'returns error message' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => 'Story with provided Id fakestoryid not found' })
      end
    end

    context 'when story is private' do
      let(:story) { create(:story, privacy: 'private') }

      context 'when user_key belongs to the story owner' do
        before { get "/v3/stories/#{story.id.to_s}.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}" }

        it 'returns story' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq (
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
              'number_of_items'=> story.set_items.to_a.count { |item| item.type != 'text' },
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
                                'meta' => { 'size' => item.meta[:size], 'is_cover' => (item.content[:image_url] == story.cover_thumbnail) }
                              }
                            end
            }
          )
        end
      end

      context 'when user_key does not belongs to the story owner' do
        before { get "/v3/stories/#{story.id.to_s}.json?api_key=#{admin.authentication_token}&user_key=fakestoryuserkey" }

        it 'returns error message' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq ({ 'errors' => "Story with provided Id #{story.id.to_s} is private story and requires the creator's key as user_key" })
        end
      end
    end
  end

  describe '#create' do
    context 'successful post' do
      before do
        params = { story: { name: 'New Story Name' } }.to_query

        post "/v3/stories.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"
      end

      it 'returns user info of updated user' do
        story = SupplejackApi::UserSet.last
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({
          'name' => story.name,
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
          'number_of_items'=> story.set_items.to_a.count { |item| item.type != 'text' },
          'creator' => story.user.name,
          'category' => 'Other',
          'contents' => []
        })
      end
    end

    context 'failures' do
      context 'when user not found' do
        before do
          params = { story: { name: 'New Story Name' } }.to_query

          post "/v3/stories.json?api_key=#{admin.authentication_token}&user_key=fakeapiuserkey&#{params}"
        end

        it 'returns user not found error' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq ({ 'errors' => 'User with provided Api Key fakeapiuserkey not found' })
        end
      end

      context 'when story name is empty' do
        before do
          params = { story: { privacy: 'public' } }.to_query

          post "/v3/stories.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"
        end

        it 'returns mandatory param error' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq ({ 'errors' => 'Mandatory Parameter name missing in request' })
        end
      end
    end
  end

  describe '#update' do
    context 'when story id exists' do
      before do
        params = { story: { name: 'Updated Story Name' } }.to_query
  
        patch "/v3/stories/#{story.id}.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"
      end

      it 'returns user info of updated story' do
        response_attributes = JSON.parse(response.body)

        story.reload
  
        expect(response_attributes).to eq ({
          'name' => 'Updated Story Name',
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
          'number_of_items'=> story.set_items.to_a.count { |item| item.type != 'text' },
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
              'meta' => { 'size' => item.meta[:size], 'is_cover' => (item.content[:image_url] == story.cover_thumbnail) }
            }
          end
        })
      end
    end

    context 'when story id does not exist' do
      before do
        params = { story: { name: 'Updated Story Name' } }.to_query
  
        patch "/v3/stories/fakestoryid.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"
      end

      it 'returns error message' do
        response_attributes = JSON.parse(response.body)
  
        expect(response_attributes).to eq ({ 'errors' => 'Story with provided Id fakestoryid not found' })
      end
    end

    context 'when user_key belongs admin' do
      %w[featured approved].each do |admin_field|
        it "can update admin field #{admin_field}" do
          params = { story: { name: 'Updated Story Name' } }
          params[:story][admin_field] = true
          patch "/v3/stories/#{story.id}.json?api_key=#{admin.authentication_token}&user_key=#{admin.api_key}&#{params.to_query}"

          response_attributes = JSON.parse(response.body)

          expect(response_attributes[admin_field]).to eq true
        end
      end
    end

    context 'when user_key belongs no admin' do
      %w[featured approved].each do |admin_field|
        it "can not update admin field #{admin_field}" do
          params = { story: { name: 'Updated Story Name' } }
          params[:story][admin_field] = true
          patch "/v3/stories/#{story.id}.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params.to_query}"

          response_attributes = JSON.parse(response.body)

          expect(response_attributes[admin_field]).to eq false
        end
      end
    end
  end

  describe '#destroy' do
    context 'when story id does not exist' do
      before { delete "/v3/stories/fakestoryid.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}" }

      it 'returns error message' do
        response_attributes = JSON.parse(response.body)
  
        expect(response_attributes).to eq ({ 'errors' => "Story with provided Id fakestoryid not found" })
      end
    end

    context 'when story id exists' do
      before { delete "/v3/stories/#{story.id.to_s}.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}" }

      it 'returns 204' do
        expect(response.status).to eq 204
      end
    end

    context 'when user of the api_key is an admin' do
      before { delete "/v3/stories/#{story.id.to_s}.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}" }

      it 'returns 204' do
        expect(response.status).to eq 204
      end
    end

    # should be fixed
    context 'when user of the api_key is not an admin' do
      let(:user) { create(:user) }

      before { delete "/v3/stories/#{story.id.to_s}.json?api_key=#{user.authentication_token}&user_key=#{story.user.api_key}" }

      xit 'returns 401' do
        expect(response.status).to eq 401
      end
    end
  end

  describe '#admin_index' do
    context 'when requesting with wrong user_key' do
      before { get "/v3/users/fakeuserkey/stories.json?api_key=#{admin.authentication_token}" }

      it 'returns error message' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => 'User with provided Api Key fakeuserkey not found' })
      end
    end

    context 'when requesting with a user_key of the story user' do
      context 'when requested without slim flag' do
        before { get "/v3/users/#{story.user.api_key}/stories.json?api_key=#{admin.authentication_token}" }

        it 'returns stories for the user key' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq (
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
                'number_of_items'=> story.set_items.to_a.count { |item| item.type != 'text' },
                'creator' => story.user.name,
                'category' => 'Other',
                'record_ids'=> story.set_items.sort_by(&:position).map do |item|
                                 { 'record_id' => item.record_id, 'story_item_id' => item._id.to_s }
                               end
              }
            ]
          )
        end
      end
    end
  end
end
