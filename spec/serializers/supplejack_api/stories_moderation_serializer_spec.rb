

require 'spec_helper'

module SupplejackApi
  describe StoriesModerationSerializer do
    let(:user_set) { FactoryBot.create(:user_set, name: "Dogs and cats", priority: 5) }
    let(:serialized_user_set) { StoriesModerationSerializer.new(user_set).as_json }

    describe 'attributes' do
      it 'renders the id field' do
        expect(serialized_user_set).to have_key :id
      end

      it 'renders the name field' do
        expect(serialized_user_set).to have_key :name
      end

      it 'renders the count field' do
        expect(serialized_user_set).to have_key :count
      end

      it 'renders the approved field' do
        expect(serialized_user_set).to have_key :approved
      end

      it 'renders the approved field' do
        expect(serialized_user_set).to have_key :featured
      end

      it 'renders the created_at field' do
        expect(serialized_user_set).to have_key :created_at
      end

      it 'renders the updated_at field' do
        expect(serialized_user_set).to have_key :updated_at
      end
    end
  end
end
