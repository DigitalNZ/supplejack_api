

require 'spec_helper'

module SupplejackApi
  describe UserSet do

    let(:user_set) { FactoryBot.build(:user_set)}
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

      it "sets the subjects field to [] if it is nil" do
        user_set.subjects = nil
        user_set.save
        user_set.reload
        expect(user_set.subjects).to eq []
      end

      describe "set_default_privacy" do
        it "should not override the privacy if set" do
          user_set.privacy = "private"
          user_set.set_default_privacy
          expect(user_set.privacy).to eq "private"
        end
      end

      describe "#strip_html_tags" do
        it "sets the subjects field to [] if it is nil" do
          user_set.subjects = nil
          user_set.save
          user_set.reload
          expect(user_set.subjects).to eq []
        end
        it "removes html tags from the name" do
          user_set.name = "Dogs and <b>Cats</b>"
          user_set.strip_html_tags!
          expect(user_set.name).to eq "Dogs and Cats"
        end

        it "removes html tags from the description" do
          user_set.description = "Dogs and <b>Cats</b>"
          user_set.strip_html_tags!
          expect(user_set.description).to eq "Dogs and Cats"
        end

        it "removes html tags from the subjects" do
          user_set.subjects = ["Dogs", "<b>Cats</b>"]
          user_set.strip_html_tags!
          expect(user_set.subjects).to eq ["Dogs", "Cats"]
        end

        it "removes html tags from the tags" do
          user_set.tags = ["Dogs", "<b>Cats</b>"]
          user_set.strip_html_tags!
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

      describe '#reindex_if_changed' do
        before do
          allow(Sunspot).to receive(:commit).and_return("true")
        end

        let(:record) { FactoryBot.create(:record_with_fragment) }
        let(:user_set) { FactoryBot.create(:user_set) }
        context 'an active user_set has a index-able field changed' do

          before do
            allow(user_set).to receive(:record_status).and_return("active")
            allow(user_set).to receive(:record).and_return(record)
            expect(record).to receive(:index)
          end

          it 'calls sunspot index if privacy field changed' do
            user_set.update_attribute(:privacy, 'hidden')
          end

          it 'calls sunspot index if name field changed' do
            user_set.update_attribute(:name, 'A new name')
          end

          it 'calls sunspot index if description field changed' do
            user_set.update_attribute(:description, 'A new description')
          end

          it 'calls sunspot index if approved field changed' do
            user_set.update_attribute(:approved, !user_set.approved)
          end
        end

        context 'an active user_set does not have a index-able field changed' do
          before do
            allow(user_set).to receive(:record_status).and_return("active")
            expect(Sunspot).to_not receive(:index)
          end

          it 'does not call sunspot index if privacy field changed' do
            user_set.update_attribute(:privacy, user_set.privacy)
          end

          it 'does not call sunspot index if name field changed' do
            user_set.update_attribute(:name, user_set.name)
          end

          it 'does not call sunspot index if description field changed' do
            user_set.update_attribute(:description, user_set.description)
          end

          it 'does not call sunspot index if approved field changed' do
            user_set.update_attribute(:approved, user_set.approved)
          end
        end

        context 'an un-active user_set has a index-able field changed' do
          before do
            expect(Sunspot).to_not receive(:index)
          end

          it 'calls sunspot index if privacy field changed' do
            user_set.update_attribute(:privacy, 'hidden')
          end

          it 'calls sunspot index if name field changed' do
            user_set.update_attribute(:name, 'A new name')
          end

          it 'calls sunspot index if description field changed' do
            user_set.update_attribute(:description, 'A new description')
          end
        end

        context 'an un-active user_set that is approved' do
          before do
            allow(user_set).to receive(:record).and_return(record)
            expect(record).to receive(:index)
          end

           it 'calls sunspot index' do
            user_set.update_attribute(:approved, true)
          end
        end
      end
    end

    describe ".find_by_record_id" do
      it "returns a set_item by it's record_id" do
        set_item = user_set.set_items.build(record_id: 12)
        user_set.save
        expect(user_set.set_items.find_by_record_id(12)).to eq set_item
      end
    end

    describe ".find_by_id" do
      it "returns a set_item by it's id" do
        set_item = user_set.set_items.build(record_id: 12)
        user_set.save
        expect(user_set.set_items.find_by_id(set_item.id.to_s)).to eq set_item
      end
    end

    describe "relationships" do
      it "should have a single record" do
        user_set.record = SupplejackApi.config.record_class.new
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
      let(:user_set) { FactoryBot.build(:user_set, user_id: User.new.id, url: "1234abc")}

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
        user = create(:user)
        @user_set = FactoryBot.build(:user_set, user_id: user.id, url: "1234abc")
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
        @set1 = FactoryBot.create(:user_set, privacy: "public")
        @set2 = FactoryBot.create(:user_set, privacy: "hidden")
      end

      it "returns all public sets" do
        expect(UserSet.public_sets).to eq([@set1])
      end

      it "ignores favourites" do
        @set3 = FactoryBot.create(:user_set, privacy: "public", name: "Favourites")
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

    describe '#public_search' do
      let!(:user_set1) { create(:user_set_with_set_item, name: 'Name 1', updated_at: Date.parse('2019-1-1')) }
      let!(:user_set2) { create(:user_set, name: 'Name 2', updated_at: Date.parse('2011-1-1')) }
      let!(:user_set3) { create(:user_set, name: 'Name 4', updated_at: Date.parse('2012-1-1')) }
      let!(:user_set4) { create(:user_set, name: 'Name 3', updated_at: Date.parse('2010-1-1')) }
      let!(:user_set5) { create(:user_set, name: 'abcdef', updated_at: Date.parse('2009-1-1')) }

      it 'calls where, paginate and order' do
        expect(UserSet).to receive(:where).and_call_original
        expect_any_instance_of(Mongoid::Criteria).to receive(:order).with({ updated_at: :asc }).and_call_original
        expect_any_instance_of(Mongoid::Criteria).to receive(:page).with(1).and_call_original
        # After calling page, Kaminari assigns dynamically the `per` method.
        expect_any_instance_of(Kaminari::PageScopeMethods).to receive(:per).with(10)

        UserSet.public_search
      end

      it 'returns a Mongoid::Criteria' do
        expect(UserSet.public_search).to be_a(Mongoid::Criteria)
      end

      it 'returns the good 4 sets with "Name" search term' do
        sets = UserSet.public_search(page: 1, per_page: 10, orderby: :updated_at, direction: :desc, search: 'Name').to_a

        expect(sets.length).to eq(4)
        expect(sets).to eq([user_set1, user_set3, user_set2, user_set4])
      end

      it 'is case insensitive' do
        sets = UserSet.public_search(page: 1, per_page: 10, orderby: :updated_at, direction: :desc, search: 'name').to_a

        expect(sets.length).to eq(4)
        expect(sets).to eq([user_set1, user_set3, user_set2, user_set4])
      end

      it 'returns the good set with "story_id" search term' do
        sets = UserSet.public_search(page: 1, per_page: 10, orderby: :updated_at, direction: :desc, search: user_set1.id.to_s).to_a

        expect(sets.length).to eq(1)
        expect(sets).to eq([user_set1])
      end

      it 'returns the good set with "user_id" search term' do
        sets = UserSet.public_search(page: 1, per_page: 10, orderby: :updated_at, direction: :desc, search: user_set1.user_id.to_s).to_a

        expect(sets.length).to eq(1)
        expect(sets).to eq([user_set1])
      end

      it 'returns 3 sets if per_page=3' do
        sets = UserSet.public_search(page: 1, per_page: 3, order_by: :updated_at, direction: :desc).to_a

        expect(sets.length).to eq(3)
        expect(sets).to eq([user_set1, user_set3, user_set2])
      end

      it 'returns 2 sets if page=2 and per_page=3' do
        sets = UserSet.public_search(page: 2, per_page: 3, order_by: :updated_at, direction: :desc).to_a

        expect(sets.length).to eq(2)
        expect(sets).to eq([user_set4, user_set5])
      end
    end

    describe "#featured_sets" do
      before :each do
        @record = FactoryBot.create(:record, status: "active")
        @set1 = FactoryBot.create(:user_set, privacy: "public", featured: true, featured_at: Time.zone.now - 4.hours)
        @set1.set_items.create(record_id: @record.record_id)
        @set2 = FactoryBot.create(:user_set, privacy: "hidden", featured: true)
        @set2.set_items.create(record_id: @record.record_id)
        @set3 = FactoryBot.create(:user_set, privacy: "public", featured: false)
        @set3.set_items.create(record_id: @record.record_id)
      end

      it "returns public sets" do
        expect(UserSet.featured_sets.to_a).to eq [@set1]
      end

      it "orders the sets based on when they were added" do
        @set4 = FactoryBot.create(:user_set, privacy: "public", featured: true, featured_at: Time.zone.now)
        @set4.set_items.create(record_id: @record.record_id)
        expect(UserSet.featured_sets.first).to eq @set4
      end

      it "doesn't return sets without active records" do
        @set4 = FactoryBot.create(:user_set, privacy: "public", featured: true, name: "No records")
        expect(UserSet.featured_sets).to_not include(@set4)
      end
    end

    describe "#update_attributes_and_embedded" do
      before {
        developer = double(:developer)
        admin = double(:admin, admin: true, role: 'admin')
        allow(RecordSchema).to receive(:roles) { { admin: admin, developer: developer } }
      }

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

      # With new mongoid, I don't think we need this test anymore. Mongoid throws an error, which is healthy
      # it "ignores invalid attributes" do
      #   user_set.update_attributes_and_embedded(something: "Bad attribute")
      #   user_set.reload
      #   expect(user_set[:something]).to be_nil
      # end

      it "ignores invalid set item values but still saves the set" do
        user_set.update_attributes_and_embedded(records: [{"record_id" => "13", "position" => "1"}, {"record_id" => "shtig", "position" => "2"}])
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
        regular_user = FactoryBot.create(:user, role: "developer")
        user_set = FactoryBot.create(:user_set, user_id: regular_user.id, featured: false)
        user_set.update_attributes_and_embedded({featured: true}, regular_user)
        user_set.reload
        expect(user_set.featured).to be_falsey
      end

      it "should allow admins to change the :featured attribute" do
        admin_user = FactoryBot.create(:user, role: "admin")
        user_set = FactoryBot.create(:user_set, user_id: admin_user.id)
        user_set.update_attributes_and_embedded({featured: true}, admin_user)
        user_set.reload
        expect(user_set.featured).to be_truthy
      end

      it "should update the featured_at when the featured attribute is updated" do
        admin_user = FactoryBot.create(:user, role: "admin")
        user_set = FactoryBot.create(:user_set, user_id: admin_user.id)
        Timecop.freeze(Time.zone.now) do
          user_set.update_attributes_and_embedded({featured: true}, admin_user)
          user_set.reload
          expect(user_set.featured_at.to_i).to eq Time.zone.now.to_i
        end
      end

      it "should not update the featured_at if the featured hasn't changed" do
        admin_user = FactoryBot.create(:user, role: "admin")
        time = Time.zone.now-1.day
        user_set = FactoryBot.create(:user_set, user_id: admin_user.id, featured: true, featured_at: time)
        Timecop.freeze(Time.zone.now) do
          user_set.update_attributes_and_embedded({featured: true}, admin_user)
          user_set.reload
          expect(user_set.featured_at.to_i).to eq time.to_i
        end
      end

      it "removes the set from the featured" do
        admin_user = FactoryBot.create(:user, role: "admin")
        time = Time.zone.now-1.day
        user_set = FactoryBot.create(:user_set, user_id: admin_user.id, featured: true, featured_at: time)
        user_set.update_attributes_and_embedded({featured: false}, admin_user)
        user_set.reload
        expect(user_set.featured).to be_falsey
      end

      it "initializes the set_items through the user_set" do
        item = user_set.set_items.build(record_id: 13)
        expect(user_set.set_items).to receive(:find_by_record_id).with('13') { item }
        user_set.update_attributes_and_embedded(records: [{"record_id" => "13", "position" => nil}])
      end

      it "can replace the set items" do
        user_set.save
        user_set.set_items.create(record_id: 13, :type=>"embed", :sub_type=>"record", :content=>{:record_id=>"13"}, :meta=>{:align_mode=>0})
        user_set.update_attributes_and_embedded(records: [{"record_id" => "13", "position" => nil, :type=>"embed", :sub_type=>"record", :content=>{:record_id=>"13"}, :meta=>{:align_mode=>0}}])
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

      it "overrides nil value for description" do
        user_set.save
        user_set.update_attributes_and_embedded(description: nil)
        user_set.reload
        expect(user_set.description).to eq ''
      end

      it "overrides nil value for description" do
        user_set.save
        user_set.update_attributes_and_embedded(approved: nil)
        user_set.reload
        expect(user_set.approved).to eq false
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
      let(:user_set) { FactoryBot.build(:user_set)}
      before(:each) do
        allow(user_set).to receive(:update_record).and_call_original
        allow(SupplejackApi.config.record_class).to receive(:custom_find) { double(:record).as_null_object }
      end

      context "user set attributes" do
        before(:each) do
          allow(user_set).to receive(:set_items) { [double(:set_item).as_null_object] }
        end

        # I have introduced a user set before create call back, so we don't need this anymore.
        # it "should create a new record if not linked" do
        #   expect(Supplejack.config.record_class).to receive(:new) { mock_model(SupplejackApi.config.record_class).as_null_object }
        #   user_set.update_record
        # end

        it "should not create a new record if already linked" do
          allow(user_set).to receive(:record) { double(:record).as_null_object }
          expect(SupplejackApi.config.record_class).to_not receive(:new)
          user_set.update_record
        end

        context "record status" do
          let(:user_set) { FactoryBot.build(:user_set)}
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
        @record = FactoryBot.build(:record)
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

      it "should get the active record objects included in the set" do
        @record1 = FactoryBot.create(:record, status: "active")
        @record2 = FactoryBot.create(:record, status: "deleted")
        allow(user_set).to receive(:record_ids){[@record1.record_id,@record2.record_id]}
        expect(user_set.records).to eq([@record1])
      end

      it "limits the amount of records" do
        @record1 = FactoryBot.create(:record, status: "active")
        @record2 = FactoryBot.create(:record, status: "active")
        allow(user_set).to receive(:record_ids){[@record1.record_id,@record2.record_id]}
        expect(user_set.records(1)).to eq([@record1])
      end

      it "it returns the first active record" do
        @record1 = FactoryBot.create(:record, status: "deleted")
        @record2 = FactoryBot.create(:record, status: "active")
        allow(user_set).to receive(:record_ids){[@record1.record_id,@record2.record_id]}
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
        expect(user_set.subjects).to include("dogs", "cats", "animals")
      end

      it "removes empty tags" do
        user_set.tag_list = "dogs, , animals"
        expect(user_set.subjects.size).to eq(2)
      end

      it "handles a nil tag list" do
        user_set.tag_list = nil
        expect(user_set.tags).to be_empty
      end

      it "strips tags from punctuations except - and _" do
        user_set.tag_list = "hola! d-a_s_h @#$\%^&*()+=.;: ,something else"
        expect(user_set.subjects).to eq ["hola d-a_s_h", "something else"]
      end
    end

    describe "#tag_list" do
      it "returns a comma seperated list of tags" do
        user_set.subjects = ["animal","dog","beast"]
        expect(user_set.tag_list).to eq("animal, dog, beast")
      end

      it "returns an empty string when tags is nil" do
        user_set.tags = nil
        expect(user_set.tag_list).to be_nil
      end
    end

    describe "#items_with_records" do
      it "returns an array of set items with record information" do
        record = FactoryBot.create(:record)
        fragment = record.fragments.create( title: "Dog", description: "Ugly dog", display_content_partner: "ATL", display_collection: "Display collection", large_thumbnail_attributes: {url: "goo.gle/large"}, thumbnail_attributes: {url: "goo.gle/small"})
        user_set.set_items.build(record_id: record.record_id, position: 1)
        expect(user_set.items_with_records.first.record).to eq record
      end

      it "removes set items which don't have a corresponding record" do
        user_set.set_items.build(record_id: 5, position: 1)
        expect(user_set.items_with_records.size).to eq 0
      end

      it "returns items_with_records sorted by position" do
        r1 = FactoryBot.create(:record)
        r2 = FactoryBot.create(:record)
        user_set.set_items.build(record_id: r1.record_id, position: 2)
        user_set.set_items.build(record_id: r2.record_id, position: 1)
        expect(user_set.items_with_records[0].record_id).to eq r2.record_id
        expect(user_set.items_with_records[1].record_id).to eq r1.record_id
      end

      it "only fetches the amount of records specified" do
        record = FactoryBot.create(:record)
        user_set.set_items.build(record_id: 5, position: 2)
        user_set.set_items.build(record_id: record.record_id, position: 1)
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
        expect(SupplejackApi.config.record_class).to receive(:custom_find).with(5) { record5 }
        expect(SupplejackApi.config.record_class).to receive(:custom_find).with(6) { record6 }
        expect(record5).to receive(:index)
        expect(record6).to receive(:index)
        user_set.reindex_items
      end
    end

  end
end
