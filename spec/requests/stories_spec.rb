require 'spec_helper'

RSpec.describe 'Stories', type: :request do
  let(:admin) { create(:admin_user) }
  let(:story) { create(:story) }

  describe 'index' do
    context 'when requesting without a user_key' do
      before { get "/v3/stories.json?api_key=#{admin.authentication_token}" }

      it 'returns an error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => 'Mandatory parameter user_key missing' })
      end
    end

    context 'when requesting with a user_key' do
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
  end

  describe 'show' do
    before { get "/v3/stories/#{story.id.to_s}.json?api_key=#{admin.authentication_token}" }

    it 'returns user info' do
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

  describe 'create' do
    before do
      params = { story: { name: 'New Story Name' } }.to_query

      post "/v3/stories.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"
    end

    it 'returns user info of updated user' do
      story = SupplejackApi::UserSet.last
      response_attributes = JSON.parse(response.body)

      expect(response_attributes).to eq ({ 'name' => story.name,
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

  describe 'update' do
    before do
      params = { story: { name: 'Updated Story Name' } }.to_query

      patch "/v3/stories/#{story.id}.json?api_key=#{admin.authentication_token}&user_key=#{story.user.api_key}&#{params}"
    end

    it 'returns user info of updated user' do
      response_attributes = JSON.parse(response.body)

      story.reload

      expect(response_attributes).to eq ({ 'name' => 'Updated Story Name',
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
end

DEFAULT_CONTENT_PRESENTER = lambda do |block|
  result = {}

  block.content.each do |k, v|
    result[k.to_s] = v
  end

  result
end
