# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe UserSerializer do
    let(:user) { FactoryGirl.create(:user) }
    let(:serialized_user) { described_class.new(user).as_json }

    it 'renders the :id' do
      expect(serialized_user).to have_key :id
    end

    it 'renders the :name' do
      expect(serialized_user).to have_key :name
    end

    it 'renders the :email' do
      expect(serialized_user).to have_key :email
    end

    it 'renders the :username' do
      expect(serialized_user).to have_key :username
    end

    it 'renders the :api_key' do
      expect(serialized_user).to have_key :api_key
    end
  end
end
