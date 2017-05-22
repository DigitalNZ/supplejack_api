# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe StoriesModerationSerializer do
    let(:user_set) { FactoryGirl.create(:user_set, name: "Dogs and cats", priority: 5) }
    let(:serialized_user_set) { StoriesModerationSerializer.new(user_set).as_json[:stories_moderation] }

    describe 'attributes' do
      it 'renders the id field' do
        expect(serialized_user_set).to have_key :id
      end

      it 'renders the name field' do
        expect(serialized_user_set).to have_key :name
      end

      it 'renders the user field' do
        expect(serialized_user_set).to have_key :user
      end

      it 'renders the count field' do
        expect(serialized_user_set).to have_key :count
      end

      it 'renders the approved field' do
        expect(serialized_user_set).to have_key :approved
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

