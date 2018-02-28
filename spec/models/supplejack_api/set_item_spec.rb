

require 'spec_helper'

module SupplejackApi
  describe SetItem do

  	let(:user_set) { FactoryBot.build(:user_set) }
    let(:set_item) { user_set.set_items.build(record_id: 10, position: 1) }

    before(:each) do
      allow(user_set).to receive(:record) {double(:record, record_id: 4321, touch: true)}
      allow(user_set).to receive(:update_record)
    end

    context "validations" do
      it "should not be valid when record_id is not a number" do
        set_item.record_id = "abc"
        expect(set_item).to_not be_valid
      end

      it "should be valid when the record_id is a number in string format" do
        set_item.record_id = "1234"
        expect(set_item.record_id).to eq 1234
        expect(set_item).to be_valid
      end

      it "should not be valid when the record_id already exists in another set item" do
        user_set.set_items.build(record_id: 2, position: 1)
        user_set.save
        set_item = user_set.set_items.build(record_id: 2, position: 2)
        expect(set_item).to_not be_valid
      end

      it "should not be valid when trying to add a set to itself" do
        allow(user_set).to receive(:record) {double(:record, record_id: 1234)}
        user_set.set_items.build(record_id: 1234, position: 1)
        set_item = user_set.set_items.first
        expect(set_item).to_not be_valid
      end

      it "should allow set_item to be added to user_set without an associated Record" do
        allow(user_set).to receive(:record)
        user_set.set_items.build(record_id: 1234, position: 1)
        set_item = user_set.set_items.first
        expect(set_item).to be_valid
      end
    end

    context "callbacks" do
      it "calls set_position before_validation" do
        set_item = user_set.set_items.build(record_id: 20)
        expect(set_item).to receive(:set_position)
        set_item.save
      end

       it "updates the user_set updated at field when an item is updated and saved" do
        old_time = user_set.updated_at
        set_item.position = 2
        set_item.save!

        expect(user_set.updated_at).to_not eq old_time
      end



    end

    it "delegates record fields to the :record object" do
      set_item.record = FactoryBot.create(:record, record_id: 5)
      set_item.record.fragments.create(name: "Ben", address: "Wellington")
      set_item.record.save

      expect(set_item.name).to eq "Ben"
      expect(set_item.address).to eq "Wellington"
    end

    it "returns nil for any record field if the record doesn't exist" do
      [:name, :address].each do |attr|
        expect(set_item.send(attr)).to be_nil
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
          expect(set_item.position).to eq 2
        end

        it "doesn't override the position when already set" do
          set_item = user_set.set_items.build(record_id: 2, position: 4)
          set_item.set_position
          expect(set_item.position).to eq 4
        end
      end

      context "without set items" do
        it "sets the position to 1" do
          set_item = user_set.set_items.build(record_id: 2)
          set_item.set_position
          expect(set_item.position).to eq 1
        end
      end
    end

    describe "#reindex_record" do
      let(:record) {double(:record)}

      it "finds the record and calls index" do
        expect(Record).to receive(:custom_find).with(set_item.record_id) {record}
        expect(record).to receive(:index)
        set_item.reindex_record
      end
    end


    describe 'hash fields' do
      it 'symbolizes the keys on the hash fields when created' do
        set_item = create(:story_item)

        expect(set_item.meta).to have_key :size
        expect(set_item.content).to have_key :value
      end

      it 'symbolizes the keys on the hash fields when found' do
        set_item = create(:story_item)
        set_item = UserSet.find(set_item.user_set.id).set_items.first

        expect(set_item.meta).to have_key :size
        expect(set_item.content).to have_key :value
      end
    end
  end
end
