# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe Record do
    let(:record) { build(:record) }

    subject { record }

    describe '#custom_find' do
      before(:each) do
        @record = create(:record)
        allow(@record).to receive(:find_next_and_previous_records).and_return(nil)
      end

      it 'should search for a record via its record_id' do
        expect(Record.custom_find(@record.record_id)).to eq(@record)
      end

      it 'should search for a record via its ObjectId (MongoDB autoassigned id)' do
        expect(Record.custom_find(@record.id)).to eq(@record)
      end

      it 'should raise a error when a record is not found' do
        expect { Record.custom_find(111) }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end

      it "shouldn't call find when the mongo id is invalid" do
        expect(Record).to_not receive(:find)
        expect { Record.custom_find('1234567abc') }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end

      it 'should find next and previous records' do
        @user = double(:user)
        allow(Record).to receive_message_chain(:unscoped, :active, :where, :first).and_return(@record)
        expect(@record).to receive(:find_next_and_previous_records).with(@user, { text: 'dogs' })
        Record.custom_find(@record.record_id, @user, { text: 'dogs' })
      end

      [Sunspot::UnrecognizedFieldError, Timeout::Error, Errno::ECONNREFUSED, Errno::ECONNRESET].each do |error_klass|
        it "should rescue from a #{error_klass}" do
          allow(Record).to receive_message_chain(:unscoped, :active, :where, :first).and_return(@record)
          allow(@record).to receive(:find_next_and_previous_records).and_raise(error_klass)
          Record.custom_find(@record.record_id, nil, { text: 'dogs' })
        end
      end

      it 'should rescue from a RSolr::Error::Http' do
        allow(Record).to receive_message_chain(:unscoped, :active, :where, :first).and_return(@record)
        allow(@record).to receive(:find_next_and_previous_records).and_raise(RSolr::Error::Http.new({}, {}))
        Record.custom_find(@record.record_id, nil, { text: 'dogs' })
      end

      context 'restricting inactive records' do
        it 'finds only active records' do
          @record.update_attribute(:status, 'deleted')
          @record.reload
          expect { Record.custom_find(@record.record_id) }.to raise_error(Mongoid::Errors::DocumentNotFound)
        end

        it 'finds also inactive records when :status => :all' do
          @record.update_attribute(:status, 'deleted')
          @record.reload
          expect(Record.custom_find(@record.record_id, nil, { status: :all })).to eq @record
        end

        it "doesn't find next and previous record without any search options" do
          allow(Record).to receive_message_chain(:unscoped, :where, :first) { @record }
          expect(@record).to_not receive(:find_next_and_previous_records)
          Record.custom_find(@record.record_id, nil, { status: :all })
        end

        it "doesn't break with nil options" do
          expect(Record.custom_find(@record.record_id, nil, nil)).to eq @record
        end
      end
    end

    describe '#find_multiple' do
      before(:each) do
        @record = create(:record)
      end

      it 'should find multiple records by numeric id' do
        r1 = create(:record)
        r2 = create(:record)
        expect(Record.find_multiple([r1.record_id, r2.record_id])).to include(r1, r2)
        expect(Record.find_multiple([r1.record_id, r2.record_id]).length).to eq(2)
      end

      it 'should find multiple records by ObjectId' do
        r1 = create(:record)
        r2 = create(:record)
        expect(Record.find_multiple([r1.id, r2.id])).to include(r1, r2)
        expect(Record.find_multiple([r1.id, r2.id]).length).to eq(2)
      end

      it "should find multiple records with ObjectId's and numeric id's" do
        r1 = create(:record, record_id: 997)
        r2 = create(:record)
        expect(Record.find_multiple([r1.record_id, r2.id])).to include(r1, r2)
        expect(Record.find_multiple([r1.record_id, r2.id]).length).to eq(2)
      end

      it 'returns an empty array when ids is nil' do
        expect(Record.find_multiple(nil)).to eq []
      end

      it 'should not return inactive records' do
        r1 = create(:record, status: 'deleted')
        r2 = create(:record, status: 'active')
        records = Record.find_multiple([r1.record_id, r2.record_id]).to_a
        expect(records).to_not include(r1)
        expect(records).to include(r2)
      end

      it 'returns the records in the same order as requested' do
        r1 = create(:record, created_at: Time.now.utc - 10.days)
        r2 = create(:record, created_at: Time.now.utc)
        records = Record.find_multiple([r2.record_id, r1.record_id]).to_a
        expect(records.first).to eq r2
      end

      context 'when record ids are passed as strings' do
        it 'returns the records in the same order as requested' do
          r1 = create(:record, created_at: Time.now.utc - 10.days)
          r2 = create(:record, created_at: Time.now.utc)
          records = Record.find_multiple([r2.record_id.to_s, r1.record_id.to_s]).to_a
          expect(records.first).to eq r2
        end
      end
    end

    describe '#find_next_and_previous_records' do
      pending 'Implement record search'
      # before(:each) do
      #   @record = create(:record, :record_id => 123)
      #   @search = Search.new
      #   @search.stub(:total).and_return(3)
      #   Search.stub(:new).and_return(@search)
      #   @user = build(:user)
      # end

      # it 'should not do anything when options are empty' do
      #   Search.should_not_receive(:new)
      #   record.find_next_and_previous_records(@user, {})
      # end

      # it 'should not do anything when options is null' do
      #   Search.should_not_receive(:new)
      #   record.find_next_and_previous_records(@user, nil)
      # end

      # it 'should not do anything when the solr request fails' do
      #   @search.stub(:valid?) { false }
      #   @search.should_not_receive(:hits)
      #   record.find_next_and_previous_records(@user, {text: 'dogs'})
      # end

      # it 'should set the scope in the search' do
      #   Search.stub(:new) { @search }
      #   @search.should_receive('scope=').with(@user)
      #   record.find_next_and_previous_records(@user, {text: 'dogs'})
      # end

      # context 'records within the current page' do
      #   before do
      #     Record.stub(:find).with('12345') {mock_model(Record, :record_id => 654)}
      #     Record.stub(:find).with('98765') {mock_model(Record, :record_id => 987)}
      #   end

      #   it 'should set the previous record' do
      #     @search.stub(:hits) { mock_hits(['12345', @record.id, '98765']) }
      #     Record.should_receive(:find).with('12345').and_return(mock_model(Record, :record_id => 654))
      #     @record.find_next_and_previous_records(@user, text: 'dogs')
      #     @record.previous_record).to eq(654)
      #   end

      #   it 'should set the next record' do
      #     @search.stub(:hits).and_return(mock_hits([nil, @record.id, '98765']))
      #     Record.should_receive(:find).with('98765').and_return(mock_model(Record, :record_id => 987))
      #     @record.find_next_and_previous_records(@user, {text: 'dogs'})
      #     @record.next_record).to eq(987)
      #   end
      # end

      # context 'first record in the results' do
      #   before(:each) do
      #     @search.stub(:hits).and_return(mock_hits([@record.id, '12345', '98765']))
      #   end

      #   it 'should perform a new search for the previous page' do
      #     @search.stub(:page).and_return(2)
      #     Search.should_receive(:new).with(anything)
      #     Search.should_receive(:new).with(hash_including(page: 1))
      #     @record.find_next_and_previous_records(@user, {text: 'dogs'})
      #     @record.previous_page).to eq(1)
      #   end

      #   it 'should not perform a new search when in the first page' do
      #     @search.stub(:hits).and_return(mock_hits([@record.id, '12345', '98765']))
      #     Search.should_receive(:new).once
      #     @record.find_next_and_previous_records(@user, {text: 'dogs'})
      #     @record.previous_record).to be_nil
      #   end
      # end

      # context 'last record in the results' do
      #   before(:each) do
      #     @search.stub(:hits).and_return(mock_hits(['12345', '98765', @record.id]))
      #     @search.stub(:per_page).and_return(3)
      #   end

      #   it 'should perform a new search for the next page' do
      #     @search.stub(:total).and_return(6)
      #     Search.should_receive(:new).with(anything)
      #     Search.should_receive(:new).with(hash_including(page: 2))
      #     @record.find_next_and_previous_records(@user, {text: 'dogs'})
      #     @record.next_page).to eq(2)
      #   end

      #   it 'should not perform a new search when in the last page' do
      #     @search.stub(:total).and_return(3)
      #     Search.should_receive(:new).once
      #     @record.find_next_and_previous_records(@user, {text: 'dogs'})
      #     @record.next_record).to be_nil
      #   end
      # end
    end

    def mock_hits(primary_keys = [])
      primary_keys.map { |pk| double(:hit, primary_key: pk.to_s) }
    end

    # describe 'harvest_job_id=()' do
    #   it 'finds a harvest job and assigns it to harvest_job' do
    #     harvest_job = create(:harvest_job, harvest_job_id: 13)
    #     record = Record.new(harvest_job_id: 13)
    #     record.harvest_job).to eq(harvest_job)
    #   end

    #   it 'returns nil for a non existent harvest job' do
    #     record = Record.new(harvest_job_id: 13)
    #     record.harvest_job).to be_nil
    #   end
    # end

    describe '#active?' do
      before(:each) do
        @record = build(:record)
      end

      it 'returns true when state is active' do
        @record.status = 'active'
        expect(@record.active?).to be_truthy
      end

      it 'returns false when state is deleted' do
        @record.status = 'deleted'
        expect(@record.active?).to be_falsey
      end
    end

    describe '#should_index?' do
      before(:each) do
        @record = build(:record)
      end

      it 'returns false when active? is false' do
        allow(@record).to receive(:active?) { false }
        expect(@record.should_index?).to be_falsey
      end

      it 'returns true when active? is true' do
        allow(@record).to receive(:active?) { true }
        expect(@record.should_index?).to be_truthy
      end
    end

    describe '#replace_stories_cover' do
      let(:set_item1) { story.set_items.first }
      let(:set_item_1_thumb) { 'https://deleted.example.com' }
      let(:set_item2) { story.set_items.last }
      let(:set_item_2_thumb) { 'https://valid.example.com' }
      let(:story) do
        create(
          :story,
          cover_thumbnail: set_item_1_thumb,
          set_items: [
            create(:embed_dnz_item, title: 'last',  position: 1, image_url: set_item_1_thumb),
            create(:embed_dnz_item, title: 'first', position: 2, image_url: set_item_2_thumb)
          ]
        )
      end

      before(:each) do
        set_item1.record.fragments << build(:fragment, large_thumbnail_url: set_item_1_thumb)
        set_item2.record.fragments << build(:fragment, large_thumbnail_url: set_item_2_thumb)

        set_item1.record.reload.save! # Without this, source_ids validation fails ...
        set_item2.record.reload.save!
      end

      it 're-sets the cover_image of any stories if the Record is the cover image' do
        expect(story.cover_thumbnail).to eq set_item_1_thumb

        set_item1.record.update!(status: :deleted) # Triggers #replace_stories_cover

        expect(story.reload.cover_thumbnail).to eq set_item_2_thumb
      end

      it 'does nothing if the record has active status' do
        expect(story.cover_thumbnail).to eq set_item_1_thumb

        set_item1.record.replace_stories_cover

        expect(story.reload.cover_thumbnail).to eq set_item_1_thumb
      end
    end
  end

  describe '#mark_for_indexing' do
    let(:record) { build(:record, index_updated: true, index_updated_at: Time.current) }

    it 'sets index_updated to be false when changes are made to a record' do
      expect(record.index_updated).to eq true
      expect(record.index_updated_at).to be_a(Date)
      record.update(status: 'active')

      record.reload

      expect(record.index_updated).to eq false
      expect(record.index_updated_at).to eq nil
    end
  end

  describe '#ready_for_indexing' do
    let!(:record_for_indexing) { create(:record_with_fragment, :ready_for_indexing) }

    it 'returns records that are ready for indexing' do
      expect(SupplejackApi::Record.ready_for_indexing.count).to eq 1
    end
  end
end
