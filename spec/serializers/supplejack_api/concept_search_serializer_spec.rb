# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe ConceptSearchSerializer do

    def serializer(options={}, attributes={})
      @user = FactoryGirl.build(:user, attributes)
      @serializer = ConceptSearchSerializer.new(@user, options)
    end

    describe '#default?' do
      it 'should return true when default is part of the groups' do
        expect(serializer(groups: [:default]).default?).to be_truthy
      end

      it 'should return false when the group is verbose' do
        expect(serializer(groups: [:verbose]).default?).to be_falsey
      end

      it 'should return false' do
        expect(serializer(groups: nil).default?).to be_falsey
        expect(serializer(groups: []).default?).to be_falsey
      end
    end
  end

end
