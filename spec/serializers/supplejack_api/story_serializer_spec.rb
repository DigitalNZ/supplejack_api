require 'spec_helper'

module SupplejackApi
  describe StorySerializer do
    let(:story) { create(:story) }

    context 'when requested with slim' do
      let(:response) { described_class.new(story, scope: { slim: true }).as_json }

      it 'has id' do
        expect(response[:id]).to eq story.id
      end
      
      it 'has name' do
        expect(response[:name]).to eq story.name
      end
      
      it 'has description' do
        expect(response[:description]).to eq story.description
      end
      
      it 'has privacy' do
        expect(response[:privacy]).to eq story.privacy
      end
      
      it 'has copyright' do
        expect(response[:copyright]).to eq story.copyright
      end
      
      it 'has featured' do
        expect(response[:featured]).to eq story.featured
      end
      
      it 'has featured_at' do
        expect(response[:featured_at]).to eq story.featured_at
      end
      
      it 'has approved' do
        expect(response[:approved]).to eq story.approved
      end
      
      it 'has tags' do
        expect(response[:tags]).to eq story.tags
      end
      
      it 'has subjects' do
        expect(response[:subjects]).to eq story.subjects
      end
      
      it 'has updated_at' do
        expect(response[:updated_at]).to eq story.updated_at
      end
      
      it 'has cover_thumbnail' do
        expect(response[:cover_thumbnail]).to eq story.cover_thumbnail
      end

      it 'has creator' do
        expect(response[:creator]).to eq story.user.name
      end

      it 'has number_of_items' do
        expect(response[:number_of_items]).to eq story.set_items.reject { |item| item.type == 'text' }.count
      end

      it 'has record_ids' do
        record_ids = story.set_items.sort_by(&:position).map do |item|
          { record_id: item.record_id, story_item_id: item._id.to_s }
        end

        expect(response[:record_ids]).to eq record_ids
      end

      it 'does not have contents' do
        expect(response[:contents]).to eq nil
      end
    end

    context 'when requested without slim' do
      let(:response) { described_class.new(story, scope: { slim: false }).as_json }

      it 'has contents' do
        expect(response[:contents].count).to eq story.contents.count
      end
    end
  end
end
