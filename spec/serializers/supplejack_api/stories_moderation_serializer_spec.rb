

require 'spec_helper'

module SupplejackApi
  describe StoriesModerationSerializer do
    let(:user_set) { FactoryBot.build(:user_set) }
    let(:serialized_user_set) { StoriesModerationSerializer.new(user_set).as_json }

    describe 'attributes' do
      it 'has the id field' do
        expect(serialized_user_set[:id]).to eq user_set.id
      end

      it 'has the name field' do
        expect(serialized_user_set[:name]).to eq user_set.name
      end

      it 'has the count field' do
        expect(serialized_user_set[:count]).to eq user_set.count
      end

      it 'has the approved field' do
        expect(serialized_user_set[:approved]).to eq user_set.approved
      end

      it 'has the approved field' do
        expect(serialized_user_set[:featured]).to eq user_set.featured
      end

      it 'has the created_at field' do
        expect(serialized_user_set[:created_at]).to eq user_set.created_at
      end

      it 'has the updated_at field' do
        expect(serialized_user_set[:updated_at]).to eq user_set.updated_at
      end

      it 'has the featured_at field' do
        expect(serialized_user_set[:featured_at]).to eq user_set.featured_at
      end

      it 'has the privacy field' do
        expect(serialized_user_set[:privacy]).to eq user_set.privacy
      end
    end
  end
end
