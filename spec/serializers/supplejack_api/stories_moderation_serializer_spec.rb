

require 'spec_helper'

module SupplejackApi
  describe StoriesModerationSerializer do
    let(:user_set) { FactoryBot.create(:user_set, priority: 5) }
    let(:serialized_user_set) { StoriesModerationSerializer.new(user_set).as_json }

    describe 'attributes' do
      it 'has id field' do
        expect(serialized_user_set[:id]).to eq user_set.id
      end

      it 'has name field' do
        expect(serialized_user_set[:name]).to eq user_set.name
      end

      it 'has count field' do
        expect(serialized_user_set[:count]).to eq user_set.count
      end

      it 'has approved field' do
        expect(serialized_user_set[:approved]).to eq user_set.approved
      end

      it 'has approved field' do
        expect(serialized_user_set[:featured]).to eq user_set.featured
      end

      it 'has created_at field' do
        expect(serialized_user_set[:created_at]).to eq user_set.created_at
      end

      it 'has updated_at field' do
        expect(serialized_user_set[:updated_at]).to eq user_set.updated_at
      end

      it 'has updated_at field' do
        expect(serialized_user_set[:username]).to eq user_set.username
      end
    end
  end
end
