# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe RecordSearchSerializer do
  
    def serializer(options={}, attributes={})
      @user = FactoryGirl.build(:user, attributes)  
      @serializer = RecordSearchSerializer.new(@user, options)
    end

    describe '#default?' do
      it 'should return true when default is part of the groups' do
        serializer(groups: [:default]).default?.should be_true
      end
      
      it 'should return false when the group is verbose' do
        serializer(groups: [:verbose]).default?.should be_false
      end
      
      it 'should return false' do
        serializer(groups: nil).default?.should be_false
        serializer(groups: []).default?.should be_false
      end
    end  
  end

end