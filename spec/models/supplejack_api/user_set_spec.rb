# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe UserSet do
    
    let(:user_set) { FactoryGirl.build(:user_set)}

  before(:each) do
    user_set.stub(:update_record)
    user_set.stub(:reindex_items)
  end

  context "validations" do
    it "is not valid without a name" do
      user_set.name = nil
      user_set.should_not be_valid
    end

    ["public", "hidden", "private"].each do |privacy|
      it "is valid with a #{privacy} privacy" do
        user_set.privacy = privacy
        user_set.should be_valid
      end
    end

    it "is not valid with another privacy setting" do
      user_set.privacy = "admin"
      user_set.should_not be_valid
    end
  end

  context "callbacks" do
    it "sets the privacy to public if not set" do
      user_set.privacy = ""
      user_set.save
      user_set.reload
      user_set.privacy.should eq "public"
    end

    describe "set_default_privacy" do
      it "should not override the privacy if set" do
        user_set.privacy = "private"
        user_set.set_default_privacy
        user_set.privacy.should eq "private"
      end
    end

    describe "#strip_html_tags" do
      it "removes html tags from the name" do
        user_set.name = "Dogs and <b>Cats</b>"
        user_set.strip_html_tags
        user_set.name.should eq "Dogs and Cats"
      end

      it "removes html tags from the description" do
        user_set.description = "Dogs and <b>Cats</b>"
        user_set.strip_html_tags
        user_set.description.should eq "Dogs and Cats"
      end

      it "removes html tags from the tags" do
        user_set.tags = ["Dogs", "<b>Cats</b>"]
        user_set.strip_html_tags
        user_set.tags.should eq ["Dogs", "Cats"]
      end
    end
  end

  describe ".find_by_record_id" do
    it "returns a set_item by it's record_id" do
      set_item = user_set.set_items.build(record_id: 12)
      user_set.save
      user_set.set_items.find_by_record_id(12).should eq set_item
    end
  end

  describe "#name" do
    let(:user_set) { FactoryGirl.build(:user_set, user_id: User.new.id, url: "1234abc")}

    it "titlizes the name" do
      user_set.name = "set name"
      user_set.name.should eq "Set name"
    end

    it "only force capitalizes the first letter" do
      user_set.name = "YMCA"
      user_set.name.should eq "YMCA"
    end
  end

  describe "#custom_find" do
    before(:each) do
      @user_set = FactoryGirl.build(:user_set, user_id: User.new.id, url: "1234abc")
      @user_set.stub(:update_record)
      @user_set.save
    end

    it "finds a user set by its default Mongo ID" do
      UserSet.custom_find(@user_set.id.to_s).should eq @user_set
    end

    it "returns nil when it doesn't find the user by Mongo ID" do
      UserSet.custom_find("111122223333444455556666").should be_nil
    end

    it "finds a user set by it's url" do
      UserSet.custom_find("1234abc").should eq @user_set
    end

    it "returns nil when id is nil" do
      UserSet.custom_find(nil).should be_nil
    end

    it "returns nil when it doesn't find the user set" do
      UserSet.custom_find("12345678").should be_nil
    end
  end

  describe "#public_sets" do
    before :each do
      @set1 = FactoryGirl.create(:user_set, privacy: "public")
      @set2 = FactoryGirl.create(:user_set, privacy: "hidden")
    end

    it "returns all public sets" do
      UserSet.public_sets.should eq([@set1])
    end

    it "ignores favourites" do
      @set3 = FactoryGirl.create(:user_set, privacy: "public", name: "Favourites")
      UserSet.public_sets.to_a.should_not include(@set3)
    end

    it "paginates the sets" do
      UserSet.public_sets(page: 2).to_a.should be_empty
    end

    it "handles an empty page parameter" do
      proxy = double(:proxy).as_null_object
      UserSet.stub(:where) { proxy }
      proxy.should_receive(:page).with(1)
      UserSet.public_sets(page: "")
    end

    it "sorts the sets by last modified date" do
      proxy = double(:proxy).as_null_object
      UserSet.stub(:where) { proxy }
      proxy.stub_chain(:desc, :page)
      proxy.should_receive(:desc).with(:created_at)
      UserSet.public_sets
    end
  end

  describe "#featured_sets" do
    before :each do
      @record = FactoryGirl.create(:record, status: "active", record_id: 1234)
      @set1 = FactoryGirl.create(:user_set, privacy: "public", featured: true, featured_at: Time.now - 4.hours)
      @set1.set_items.create(record_id: 1234)
      @set2 = FactoryGirl.create(:user_set, privacy: "hidden", featured: true)
      @set2.set_items.create(record_id: 1234)
      @set3 = FactoryGirl.create(:user_set, privacy: "public", featured: false)
      @set3.set_items.create(record_id: 1234)
    end

    it "returns public sets" do
      UserSet.featured_sets.to_a.should eq [@set1]
    end

    it "orders the sets based on when they were added" do
      @set4 = FactoryGirl.create(:user_set, privacy: "public", featured: true, featured_at: Time.now)
      @set4.set_items.create(record_id: 1234)
      UserSet.featured_sets.first.should eq @set4
    end

    it "doesn't return sets without active records" do
      @set4 = FactoryGirl.create(:user_set, privacy: "public", featured: true, name: "No records")
      UserSet.featured_sets.should_not include(@set4)
    end
  end

  describe "#update_attributes_and_embedded" do
    it "updates the set attributes" do
      user_set.update_attributes_and_embedded(name: "New dog", description: "New dog", privacy: "hidden")
      user_set.reload
      user_set.name.should eq "New dog"
      user_set.description.should eq "New dog"
      user_set.privacy.should eq "hidden"
    end

    it "updates the embedded set items" do
      user_set.update_attributes_and_embedded(records: [{"record_id" => "13", "position" => "2"}])
      user_set.reload
      user_set.set_items.size.should eq 1
      user_set.set_items.first.record_id.should eq 13
      user_set.set_items.first.position.should eq 2
    end

    it "ignores invalid attributes" do
      user_set.update_attributes_and_embedded(something: "Bad attribute")
      user_set.reload
      user_set[:something].should be_nil
    end

    it "ignores invalid set items but still saves the set" do
      user_set.update_attributes_and_embedded(records: [{"record_id" => "13", "position" => "1"}, {"position" => "2"}])
      user_set.reload
      user_set.set_items.size.should eq 1
      user_set.set_items.first.record_id.should eq 13
      user_set.set_items.first.position.should eq 1
    end

    it "ignores set_items when the format is incorrect" do
      user_set.update_attributes_and_embedded(records: {"record_id" => "13", "position" => "1"})
      user_set.reload
      user_set.set_items.size.should eq 0
    end

    it "regular users should not be able to change the :featured attribute" do
      regular_user = FactoryGirl.create(:user, role: "developer")
      user_set = FactoryGirl.create(:user_set, user_id: regular_user.id, featured: false)
      user_set.update_attributes_and_embedded({featured: true}, regular_user)
      user_set.reload
      user_set.featured.should be_false
    end

    it "should allow admins to change the :featured attribute" do
      admin_user = FactoryGirl.create(:user, role: "admin")
      user_set = FactoryGirl.create(:user_set, user_id: admin_user.id)
      user_set.update_attributes_and_embedded({featured: true}, admin_user)
      user_set.reload
      user_set.featured.should be_true
    end

    it "should update the featured_at when the featured attribute is updated" do
      admin_user = FactoryGirl.create(:user, role: "admin")
      user_set = FactoryGirl.create(:user_set, user_id: admin_user.id)
      Timecop.freeze(Time.now) do
        user_set.update_attributes_and_embedded({featured: true}, admin_user)
        user_set.reload
        user_set.featured_at.to_i.should eq Time.now.to_i
      end
    end

    it "should not update the featured_at if the featured hasn't changed" do
      admin_user = FactoryGirl.create(:user, role: "admin")
      time = Time.now-1.day
      user_set = FactoryGirl.create(:user_set, user_id: admin_user.id, featured: true, featured_at: time)
      Timecop.freeze(Time.now) do
        user_set.update_attributes_and_embedded({featured: true}, admin_user)
        user_set.reload
        user_set.featured_at.to_i.should eq time.to_i
      end
    end

    it "removes the set from the featured" do
      admin_user = FactoryGirl.create(:user, role: "admin")
      time = Time.now-1.day
      user_set = FactoryGirl.create(:user_set, user_id: admin_user.id, featured: true, featured_at: time)
      user_set.update_attributes_and_embedded({featured: false}, admin_user)
      user_set.reload
      user_set.featured.should be_false
    end

    it "initializes the set_items through the user_set" do
      item = user_set.set_items.build(record_id: 13)
      user_set.set_items.should_receive(:find_or_initialize_by).with({record_id: "13"}) { item }
      user_set.update_attributes_and_embedded(records: [{"record_id" => "13", "position" => nil}])
    end

    it "can replace the set items" do
      user_set.save
      user_set.set_items.create(record_id: 13)
      user_set.update_attributes_and_embedded(records: [{"record_id" => "13", "position" => nil}])
      user_set.reload
      user_set.set_items.size.should eq 1
      user_set.set_items.first.record_id.should eq 13
    end

    it "should not replace the set items if :records is nil" do
      user_set.save
      user_set.set_items.create(record_id: 13)
      user_set.update_attributes_and_embedded(records: nil)
      user_set.reload
      user_set.set_items.count.should eq 1
    end

    it "raises a error when then records array format is not correct" do
      expect { user_set.update_attributes_and_embedded(records: [1,2]) }.to raise_error(UserSet::WrongRecordsFormat)
    end
  end

  describe "#calculate_count" do
    it "returns 2 when there are 2 active set items" do
      user_set.stub(:records){[double(:record), double(:record)]}
      user_set.calculate_count
      user_set.count.should eq(2)
    end
  end

  describe "record_status" do
    it "should return 'active' for public and approved sets" do
      user_set.privacy = "public"
      user_set.approved = true

      user_set.record_status.should eq "active"
    end

    it "should return 'suppressed' for non-public or non-approved sets" do
      user_set.privacy = "protected"
      user_set.approved = false

      user_set.record_status.should eq "suppressed"
    end
  end

  describe "#record_ids" do
    it "returns an array of record ids for the set" do
      user_set.set_items.build(record_id:100, position:0)
      user_set.set_items.build(record_id:101, position:1)
      user_set.save
      user_set.record_ids.should include(100,101)
    end

    it "returns an empty array when set items is nil" do
      user_set.set_items = nil
      user_set.record_ids.should be_empty
    end

    it "returns the record_id's in the correct order" do
      user_set.set_items.build(record_id:100, position:1)
      user_set.set_items.build(record_id:101, position:0)
      user_set.save
      user_set.record_ids.should eq([101,100])
    end
  end

  describe "#records" do
    before :each do
      user_set.stub(:record_ids){[100,101]}
    end

    it "should get the active record objects included in the set" do
      @record1 = FactoryGirl.create(:record, record_id:100, status: "active")
      @record2 = FactoryGirl.create(:record, record_id:101, status: "deleted")
      user_set.records.should eq([@record1])
    end

    it "limits the amount of records" do
      @record1 = FactoryGirl.create(:record, record_id:100, status: "active")
      @record2 = FactoryGirl.create(:record, record_id:101, status: "active")
      user_set.records(1).should eq([@record1])
    end

    it "it returns the first active record" do
      @record1 = FactoryGirl.create(:record, record_id:100, status: "deleted")
      @record2 = FactoryGirl.create(:record, record_id:101, status: "active")
      user_set.records(1).should eq([@record2])
    end

    it "memoizes the records" do
      Record.should_receive(:find_multiple).once { [] }
      user_set.records
      user_set.records
    end
  end

  describe "#tags=" do
    it "should enforce tags to be a array" do
      user_set.tags = 1234
      user_set.tags.should eq [1234]
    end
  end

  describe "#tag_list=" do
    it "should convert the comma seperate string to an array of tags" do
      user_set.tag_list = "dogs, animals, cats"
      user_set.tags.should include("dogs", "cats", "animals")
    end

    it "removes empty tags" do
      user_set.tag_list = "dogs, , animals"
      user_set.tags.size.should eq(2)
    end

    it "handles a nil tag list" do
      user_set.tag_list = nil
      user_set.tags.should be_empty
    end

    it "strips tags from punctuations except - and _" do
      user_set.tag_list = "hola! d-a_s_h @#$\%^&*()+=.;: ,something else"
      user_set.tags.should eq ["hola d-a_s_h", "something else"]
    end
  end

  describe "#tag_list" do
    it "returns a comma seperated list of tags" do
      user_set.tags = ["animal","dog","beast"]
      user_set.tag_list.should eq("animal, dog, beast")
    end

    it "returns an empty string when tags is nil" do
      user_set.tags = nil
      user_set.tag_list.should be_nil
    end
  end

  describe "#items_with_records" do
    it "returns an array of set items with record information" do
      record = FactoryGirl.create(:record, record_id: 5)
      fragment = record.fragments.create( title: "Dog", description: "Ugly dog", display_content_partner: "ATL", display_collection: "Tapuhi", large_thumbnail_attributes: {url: "goo.gle/large"}, thumbnail_attributes: {url: "goo.gle/small"})
      user_set.set_items.build(record_id: 5, position: 1)
      user_set.items_with_records.first.record.should eq record
    end

    it "removes set items which don't have a corresponding record" do
      user_set.set_items.build(record_id: 5, position: 1)
      user_set.items_with_records.size.should eq 0
    end

    it "returns items_with_records sorted by position" do
      FactoryGirl.create(:record, record_id: 5)
      FactoryGirl.create(:record, record_id: 6)
      user_set.set_items.build(record_id: 5, position: 2)
      user_set.set_items.build(record_id: 6, position: 1)
      user_set.items_with_records[0].record_id.should eq 6
      user_set.items_with_records[1].record_id.should eq 5
    end

    it "only fetches the amount of records specified" do
      record = FactoryGirl.create(:record, record_id: 6)
      user_set.set_items.build(record_id: 5, position: 2)
      user_set.set_items.build(record_id: 6, position: 1)
      user_set.should_receive(:records).with(1) { [record] }
      user_set.items_with_records(1).size.should eq 1
    end
  end

  end
end
