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
      allow(user_set).to receive(:update_record)
      allow(user_set).to receive(:reindex_items)
    end

    context "validations" do
      it "is not valid without a name" do
        user_set.name = nil
        expect(user_set).to_not be_valid
      end

      ["public", "hidden", "private"].each do |privacy|
        it "is valid with a #{privacy} privacy" do
          user_set.privacy = privacy
          expect(user_set).to be_valid
        end
      end

      it "is not valid with another privacy setting" do
        user_set.privacy = "admin"
        expect(user_set).to_not be_valid
      end
    end

    context "callbacks" do
      it "sets the privacy to public if not set" do
        user_set.privacy = ""
        user_set.save
        user_set.reload
        expect(user_set.privacy).to eq "public"
      end

      describe "set_default_privacy" do
        it "should not override the privacy if set" do
          user_set.privacy = "private"
          user_set.set_default_privacy
          expect(user_set.privacy).to eq "private"
        end
      end

      describe "#strip_html_tags" do
        it "removes html tags from the name" do
          user_set.name = "Dogs and <b>Cats</b>"
          user_set.strip_html_tags
          expect(user_set.name).to eq "Dogs and Cats"
        end

        it "removes html tags from the description" do
          user_set.description = "Dogs and <b>Cats</b>"
          user_set.strip_html_tags
          expect(user_set.description).to eq "Dogs and Cats"
        end

        it "removes html tags from the tags" do
          user_set.tags = ["Dogs", "<b>Cats</b>"]
          user_set.strip_html_tags
          expect(user_set.tags).to eq ["Dogs", "Cats"]
        end
      end

      it "calls update_record before saving" do
        expect(user_set).to receive(:update_record)
        user_set.save
      end

      it "should mark the associated record for deletion before deleting the set" do
        expect(user_set).to receive(:delete_record)
        user_set.destroy
      end

      it "calls reindex_items after save" do
        expect(user_set).to receive(:reindex_items)
        user_set.save
      end
    end

    describe ".find_by_record_id" do
      it "returns a set_item by it's record_id" do
        set_item = user_set.set_items.build(record_id: 12)
        user_set.save
        expect(user_set.set_items.find_by_record_id(12)).to eq set_item
      end
    end

    describe "relationships" do
      it "should have a single record" do
        user_set.record = SupplejackApi::Record.new
        expect(user_set.record).to_not be_nil
      end
    end

    describe ".find_by_record_id" do
      it "returns a set_item by it's record_id" do
        set_item = user_set.set_items.build(record_id: 12)
        user_set.save
        expect(user_set.set_items.find_by_record_id(12)).to eq set_item
      end
    end

    describe "#name" do
      let(:user_set) { FactoryGirl.build(:user_set, user_id: User.new.id, url: "1234abc")}

      it "titlizes the name" do
        user_set.name = "set name"
        expect(user_set.name).to eq "Set name"
      end

      it "only force capitalizes the first letter" do
        user_set.name = "YMCA"
        expect(user_set.name).to eq "YMCA"
      end
    end

    describe "#custom_find" do
      before(:each) do
        @user_set = FactoryGirl.build(:user_set, user_id: User.new.id, url: "1234abc")
        allow(@user_set).to receive(:update_record)
        @user_set.save
      end

      it "finds a user set by its default Mongo ID" do
        expect(UserSet.custom_find(@user_set.id.to_s)).to eq @user_set
      end

      it "returns nil when it doesn't find the user by Mongo ID" do
        expect(UserSet.custom_find("111122223333444455556666")).to be_nil
      end

      it "finds a user set by it's url" do
        expect(UserSet.custom_find("1234abc")).to eq @user_set
      end

      it "returns nil when id is nil" do
        expect(UserSet.custom_find(nil)).to be_nil
      end

      it "returns nil when it doesn't find the user set" do
        expect(UserSet.custom_find("12345678")).to be_nil
      end
    end

    describe "#public_sets" do
      before :each do
        @set1 = FactoryGirl.create(:user_set, privacy: "public")
        @set2 = FactoryGirl.create(:user_set, privacy: "hidden")
      end

      it "returns all public sets" do
        expect(UserSet.public_sets).to eq([@set1])
      end

      it "ignores favourites" do
        @set3 = FactoryGirl.create(:user_set, privacy: "public", name: "Favourites")
        expect(UserSet.public_sets.to_a).to_not include(@set3)
      end

      it "paginates the sets" do
        expect(UserSet.public_sets(page: 2).to_a).to be_empty
      end

      it "handles an empty page parameter" do
        proxy = double(:proxy).as_null_object
        allow(UserSet).to receive(:where) { proxy }
        expect(proxy).to receive(:page).with(1)
        UserSet.public_sets(page: "")
      end

      it "sorts the sets by last modified date" do
        proxy = double(:proxy).as_null_object
        allow(UserSet).to receive(:where) { proxy }
        allow(proxy).to receive_message_chain(:desc, :page)
        expect(proxy).to receive(:desc).with(:created_at)
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
        expect(UserSet.featured_sets.to_a).to eq [@set1]
      end

      it "orders the sets based on when they were added" do
        @set4 = FactoryGirl.create(:user_set, privacy: "public", featured: true, featured_at: Time.now)
        @set4.set_items.create(record_id: 1234)
        expect(UserSet.featured_sets.first).to eq @set4
      end

      it "doesn't return sets without active records" do
        @set4 = FactoryGirl.create(:user_set, privacy: "public", featured: true, name: "No records")
        expect(UserSet.featured_sets).to_not include(@set4)
      end
    end

    describe "#update_attributes_and_embedded" do
      it "updates the set attributes" do
        user_set.update_attributes_and_embedded(name: "New dog", description: "New dog", privacy: "hidden")
        user_set.reload
        expect(user_set.name).to eq "New dog"
        expect(user_set.description).to eq "New dog"
        expect(user_set.privacy).to eq "hidden"
      end

      it "updates the embedded set items" do
        user_set.update_attributes_and_embedded(records: [{"record_id" => "13", "position" => "2"}])
        user_set.reload
        expect(user_set.set_items.size).to eq 1
        expect(user_set.set_items.first.record_id).to eq 13
        expect(user_set.set_items.first.position).to eq 2
      end

      it "ignores invalid attributes" do
        user_set.update_attributes_and_embedded(something: "Bad attribute")
        user_set.reload
        expect(user_set[:something]).to be_nil
      end

      it "ignores invalid set items but still saves the set" do
        user_set.update_attributes_and_embedded(records: [{"record_id" => "13", "position" => "1"}, {"position" => "2"}])
        user_set.reload
        expect(user_set.set_items.size).to eq 1
        expect(user_set.set_items.first.record_id).to eq 13
        expect(user_set.set_items.first.position).to eq 1
      end

      it "ignores set_items when the format is incorrect" do
        user_set.update_attributes_and_embedded(records: {"record_id" => "13", "position" => "1"})
        user_set.reload
        expect(user_set.set_items.size).to eq 0
      end

      it "regular users should not be able to change the :featured attribute" do
        regular_user = FactoryGirl.create(:user, role: "developer")
        user_set = FactoryGirl.create(:user_set, user_id: regular_user.id, featured: false)
        user_set.update_attributes_and_embedded({featured: true}, regular_user)
        user_set.reload
        expect(user_set.featured).to be_falsey
      end

      it "should allow admins to change the :featured attribute" do
        admin_user = FactoryGirl.create(:user, role: "admin")
        user_set = FactoryGirl.create(:user_set, user_id: admin_user.id)
        user_set.update_attributes_and_embedded({featured: true}, admin_user)
        user_set.reload
        expect(user_set.featured).to be_truthy
      end

      it "should update the featured_at when the featured attribute is updated" do
        admin_user = FactoryGirl.create(:user, role: "admin")
        user_set = FactoryGirl.create(:user_set, user_id: admin_user.id)
        Timecop.freeze(Time.now) do
          user_set.update_attributes_and_embedded({featured: true}, admin_user)
          user_set.reload
          expect(user_set.featured_at.to_i).to eq Time.now.to_i
        end
      end

      it "should not update the featured_at if the featured hasn't changed" do
        admin_user = FactoryGirl.create(:user, role: "admin")
        time = Time.now-1.day
        user_set = FactoryGirl.create(:user_set, user_id: admin_user.id, featured: true, featured_at: time)
        Timecop.freeze(Time.now) do
          user_set.update_attributes_and_embedded({featured: true}, admin_user)
          user_set.reload
          expect(user_set.featured_at.to_i).to eq time.to_i
        end
      end

      it "removes the set from the featured" do
        admin_user = FactoryGirl.create(:user, role: "admin")
        time = Time.now-1.day
        user_set = FactoryGirl.create(:user_set, user_id: admin_user.id, featured: true, featured_at: time)
        user_set.update_attributes_and_embedded({featured: false}, admin_user)
        user_set.reload
        expect(user_set.featured).to be_falsey
      end

      it "initializes the set_items through the user_set" do
        item = user_set.set_items.build(record_id: 13)
        expect(user_set.set_items).to receive(:find_or_initialize_by).with({record_id: "13"}) { item }
        user_set.update_attributes_and_embedded(records: [{"record_id" => "13", "position" => nil}])
      end

      it "can replace the set items" do
        user_set.save
        user_set.set_items.create(record_id: 13)
        user_set.update_attributes_and_embedded(records: [{"record_id" => "13", "position" => nil}])
        user_set.reload
        expect(user_set.set_items.size).to eq 1
        expect(user_set.set_items.first.record_id).to eq 13
      end

      it "should not replace the set items if :records is nil" do
        user_set.save
        user_set.set_items.create(record_id: 13)
        user_set.update_attributes_and_embedded(records: nil)
        user_set.reload
        expect(user_set.set_items.count).to eq 1
      end

      it "raises a error when then records array format is not correct" do
        expect { user_set.update_attributes_and_embedded(records: [1,2]) }.to raise_error(UserSet::WrongRecordsFormat)
      end
    end

    describe "#calculate_count" do
      it "returns 2 when there are 2 active set items" do
        allow(user_set).to receive(:records){[double(:record), double(:record)]}
        user_set.calculate_count
        expect(user_set.count).to eq(2)
      end
    end

    describe "record_status" do
      it "should return 'active' for public and approved sets" do
        user_set.privacy = "public"
        user_set.approved = true

        expect(user_set.record_status).to eq "active"
      end

      it "should return 'suppressed' for non-public or non-approved sets" do
        user_set.privacy = "protected"
        user_set.approved = false

        expect(user_set.record_status).to eq "suppressed"
      end
    end

    describe "update record" do
      before(:each) do
        allow(user_set).to receive(:update_record).and_call_original
        allow(SupplejackApi::Record).to receive(:custom_find) { double(:record).as_null_object }
      end

      context "user set attributes" do
        before(:each) do
          allow(user_set).to receive(:set_items) { [double(:set_item).as_null_object] }
        end

        it "should create a new record if not linked" do
          expect(SupplejackApi::Record).to receive(:new) { mock_model(SupplejackApi::Record).as_null_object }
          user_set.update_record
        end

        it "should not create a new record if already linked" do
          allow(user_set).to receive(:record) { double(:record).as_null_object }
          expect(SupplejackApi::Record).to_not receive(:new) 
          user_set.update_record
        end

        context "record status" do
          it "should default the status to supressed" do
            user_set.privacy = "private"

            user_set.update_record
            expect(user_set.record.status).to eq "suppressed"
          end

          it "should set the status to active if set is public and is approved" do
            user_set.privacy = "public"
            user_set.approved = true

            user_set.update_record
            expect(user_set.record.status).to eq "active"
          end
        end
      end
    end

    describe "delete_record" do
      before(:each) do
        @record = FactoryGirl.build(:record)
        allow(user_set).to receive(:record) { @record }
      end
        
      it "should set record status to deleted" do
        user_set.delete_record
        expect(user_set.record.status).to eq "deleted"
      end

      it "should save the record" do
        expect(@record).to receive(:save!)
        user_set.delete_record
      end
    end

    describe "#record_ids" do
      it "returns an array of record ids for the set" do
        user_set.set_items.build(record_id:100, position:0)
        user_set.set_items.build(record_id:101, position:1)
        user_set.save
        expect(user_set.record_ids).to include(100,101)
      end

      it "returns an empty array when set items is nil" do
        user_set.set_items = nil
        expect(user_set.record_ids).to be_empty
      end

      it "returns the record_id's in the correct order" do
        user_set.set_items.build(record_id:100, position:1)
        user_set.set_items.build(record_id:101, position:0)
        user_set.save
        expect(user_set.record_ids).to eq([101,100])
      end
    end

    describe "#records" do
      before :each do
        allow(user_set).to receive(:record_ids){[100,101]}
      end

      it "should get the active record objects included in the set" do
        @record1 = FactoryGirl.create(:record, record_id:100, status: "active")
        @record2 = FactoryGirl.create(:record, record_id:101, status: "deleted")
        expect(user_set.records).to eq([@record1])
      end

      it "limits the amount of records" do
        @record1 = FactoryGirl.create(:record, record_id:100, status: "active")
        @record2 = FactoryGirl.create(:record, record_id:101, status: "active")
        expect(user_set.records(1)).to eq([@record1])
      end

      it "it returns the first active record" do
        @record1 = FactoryGirl.create(:record, record_id:100, status: "deleted")
        @record2 = FactoryGirl.create(:record, record_id:101, status: "active")
        expect(user_set.records(1)).to eq([@record2])
      end

      it "memoizes the records" do
        expect(Record).to receive(:find_multiple).once { [] }
        user_set.records
        user_set.records
      end
    end

    describe "#tags=" do
      it "should enforce tags to be a array" do
        user_set.tags = 1234
        expect(user_set.tags).to eq [1234]
      end
    end

    describe "#tag_list=" do
      it "should convert the comma seperate string to an array of tags" do
        user_set.tag_list = "dogs, animals, cats"
        expect(user_set.tags).to include("dogs", "cats", "animals")
      end

      it "removes empty tags" do
        user_set.tag_list = "dogs, , animals"
        expect(user_set.tags.size).to eq(2)
      end

      it "handles a nil tag list" do
        user_set.tag_list = nil
        expect(user_set.tags).to be_empty
      end

      it "strips tags from punctuations except - and _" do
        user_set.tag_list = "hola! d-a_s_h @#$\%^&*()+=.;: ,something else"
        expect(user_set.tags).to eq ["hola d-a_s_h", "something else"]
      end
    end

    describe "#tag_list" do
      it "returns a comma seperated list of tags" do
        user_set.tags = ["animal","dog","beast"]
        expect(user_set.tag_list).to eq("animal, dog, beast")
      end

      it "returns an empty string when tags is nil" do
        user_set.tags = nil
        expect(user_set.tag_list).to be_nil
      end
    end

    describe "#items_with_records" do
      it "returns an array of set items with record information" do
        record = FactoryGirl.create(:record, record_id: 5)
        fragment = record.fragments.create( title: "Dog", description: "Ugly dog", display_content_partner: "ATL", display_collection: "Tapuhi", large_thumbnail_attributes: {url: "goo.gle/large"}, thumbnail_attributes: {url: "goo.gle/small"})
        user_set.set_items.build(record_id: 5, position: 1)
        expect(user_set.items_with_records.first.record).to eq record
      end

      it "removes set items which don't have a corresponding record" do
        user_set.set_items.build(record_id: 5, position: 1)
        expect(user_set.items_with_records.size).to eq 0
      end

      it "returns items_with_records sorted by position" do
        FactoryGirl.create(:record, record_id: 5)
        FactoryGirl.create(:record, record_id: 6)
        user_set.set_items.build(record_id: 5, position: 2)
        user_set.set_items.build(record_id: 6, position: 1)
        expect(user_set.items_with_records[0].record_id).to eq 6
        expect(user_set.items_with_records[1].record_id).to eq 5
      end

      it "only fetches the amount of records specified" do
        record = FactoryGirl.create(:record, record_id: 6)
        user_set.set_items.build(record_id: 5, position: 2)
        user_set.set_items.build(record_id: 6, position: 1)
        expect(user_set).to receive(:records).with(1) { [record] }
        expect(user_set.items_with_records(1).size).to eq 1
      end
    end

    describe "reindex_items" do
      let(:record5) {double(:record)}
      let(:record6) {double(:record)}
      before do
        allow(user_set).to receive(:reindex_items).and_call_original
      end

      it "finds each record can calls index" do
        user_set.set_items.build(record_id: 5, position: 1)
        user_set.set_items.build(record_id: 6, position: 2)
        expect(SupplejackApi::Record).to receive(:custom_find).with(5) { record5 }
        expect(SupplejackApi::Record).to receive(:custom_find).with(6) { record6 }
        expect(record5).to receive(:index)
        expect(record6).to receive(:index)
        user_set.reindex_items
      end
    end

  end
end
