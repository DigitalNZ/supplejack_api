require 'spec_helper'

module SupplejackApi
  describe ApplicationSerializer do 
  
    def serializer(options={}, attributes={})
      # @record = FactoryGirl.build(:record, attributes)  
      @user = FactoryGirl.build(:user, attributes)  
      @serializer = ApplicationSerializer.new(@user, options)
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
