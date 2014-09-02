# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe SetItem do
  
  	let(:user_set) { FactoryGirl.build(:user_set) }
    let(:set_item) { user_set.set_items.build(record_id: 10, position: 1) }
    
    before(:each) do
      user_set.stub(:record) {double(:record, record_id: 4321)}
    end

    context "validations" do
      it "should not be valid without a record_id" do
        set_item.record_id = nil
        set_item.should_not be_valid
      end

      it "should not be valid when record_id is not a number" do
        set_item.record_id = "abc"
        set_item.should_not be_valid
      end

      it "should be valid when the record_id is a number in string format" do
        set_item.record_id = "1234"
        set_item.record_id.should eq 1234
        set_item.should be_valid
      end

      it "should not be valid when the record_id already exists in another set item" do
        user_set.set_items.build(record_id: 2, position: 1)
        user_set.save
        set_item = user_set.set_items.build(record_id: 2, position: 2)
        set_item.should_not be_valid
      end
    end

    context "callbacks" do
      it "calls set_position before_validation" do
        set_item = user_set.set_items.build(record_id: 20)
        set_item.should_receive(:set_position)
        set_item.save
      end
    end

    describe "#set_position" do
      context "with a set item" do
        before(:each) do
          user_set.set_items.build(record_id: 1, position: 1)
          user_set.save
        end
        
        it "positions the set item at the end" do
          set_item = user_set.set_items.build(record_id: 2)
          set_item.set_position
          set_item.position.should eq 2
        end

        it "doesn't override the position when already set" do
          set_item = user_set.set_items.build(record_id: 2, position: 4)
          set_item.set_position
          set_item.position.should eq 4
        end
      end

      context "without set items" do
        it "sets the position to 1" do
          set_item = user_set.set_items.build(record_id: 2)
          set_item.set_position
          set_item.position.should eq 1
        end
      end
    end

  end
end