# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UpdateRecordFromHarvest do
  describe '#initialize' do
    let(:payload) { attributes_for(:record) }
    it 'accepts record_params' do
      expect(described_class.new(payload).payload).to eq payload
    end

    it 'defaults to a non preview record' do
      expect(described_class.new(payload).preview).to eq false
    end
  end

  describe '#call' do
    let(:payload) do
      { 'priority' => 0,
        'display_collection' => ['DNZ end to end test display_collection'],
        'primary_collection' => ['DNZ end to end test primary_collection'],
        'content_partner' => ['DNZ end to end test content_partner", "test content partner'],
        'display_content_partner' => ['DNZ end to end test display_content_partner'],
        'title' => ['DNZ end to end test title'],
        'description' => ['Exemplar record should only have 2 attachments (Attachment A and Attachment B)'],
        'subject' => ['Added in primary fragment'],
        'landing_url' => ['https://www.digitalnz.org/records/replace_this'],
        'internal_identifier' => ['end-to-end_exemplar_TEST_record-20190306T1140'],
        'job_id' => '5c7efbecf1676244abdca448',
        'source_id' => 'end_to_end_test' }
    end

    context 'record does not exist' do
      let(:record) { UpdateRecordFromHarvest.new(payload).call }

      it 'sets the internal_identifier' do
        expect(record.internal_identifier).to eq 'end-to-end_exemplar_TEST_record-20190306T1140'
      end

      it 'sets the record_type if given' do
        record = UpdateRecordFromHarvest.new(payload.merge('record_type' => 1)).call
        expect(record.record_type).to eq 1
      end

      it 'leaves the default record_type if not given' do
        expect(record.record_type).to eq 0
      end

      it 'sets single value fields on the primary_fragment' do
        expect(record.display_collection).to eq 'DNZ end to end test display_collection'
        expect(record.title).to eq 'DNZ end to end test title'
      end

      it 'sets multivalue fields on the primary fragment' do
        expect(record.content_partner).to eq(['DNZ end to end test content_partner", "test content partner'])
      end

      it 'sets the job_id' do
        expect(record.primary_fragment.job_id).to eq '5c7efbecf1676244abdca448'
      end

      it 'sets the source_id' do
        expect(record.primary_fragment.source_id).to eq 'end_to_end_test'
      end
    end

    context 'record already exists' do
      let!(:current_record_fragment) do
        build(:fragment,
              display_collection: 'current_test_display_collection',
              content_partner: %w[current_content_partner current_content_partner_two])
      end

      let!(:current_record) do
        create(:record, internal_identifier: 'end-to-end_exemplar_TEST_record-20190306T1140',
                        fragments: [current_record_fragment])
      end

      let(:record) { UpdateRecordFromHarvest.new(payload).call }

      it 'updates the correct record' do
        expect(record.record_id).to eq current_record.record_id
      end

      it 'updates the single value fields' do
        expect(record.display_collection).to eq 'DNZ end to end test display_collection'
        expect(record.title).to eq 'DNZ end to end test title'
      end

      it 'sets multivalue fields on the primary fragment' do
        expect(record.content_partner).to eq(['DNZ end to end test content_partner", "test content partner'])
      end
    end

    context 'not primary fragments' do
      let(:payload) do
        { 'priority' => -1,
          'display_collection' => ['DNZ end to end test display_collection'],
          'primary_collection' => ['DNZ end to end test primary_collection'],
          'content_partner' => ['DNZ end to end test content_partner", "test content partner'],
          'display_content_partner' => ['DNZ end to end test display_content_partner'],
          'title' => ['DNZ end to end test title'],
          'description' => ['Exemplar record should only have 2 attachments (Attachment A and Attachment B)'],
          'subject' => ['Added in primary fragment'],
          'landing_url' => ['https://www.digitalnz.org/records/replace_this'],
          'internal_identifier' => ['end-to-end_exemplar_TEST_record-20190306T1140'],
          'job_id' => '5c7efbecf1676244abdca448',
          'source_id' => 'end_to_end_test' }
      end

      let(:record) { UpdateRecordFromHarvest.new(payload).call }

      it 'sets the internal_identifier' do
        expect(record.internal_identifier).to eq 'end-to-end_exemplar_TEST_record-20190306T1140'
      end

      it 'sets single value fields on the primary_fragment' do
        expect(record.display_collection).to eq 'DNZ end to end test display_collection'
        expect(record.title).to eq 'DNZ end to end test title'
      end

      it 'sets multivalue fields on the primary fragment' do
        expect(record.content_partner).to eq(['DNZ end to end test content_partner", "test content partner'])
      end

      it 'sets the job_id' do
        expect(record.fragments.first.job_id).to eq '5c7efbecf1676244abdca448'
      end

      it 'sets the source_id' do
        expect(record.fragments.first.source_id).to eq 'end_to_end_test'
      end
    end

    context 'enrichment' do
      let!(:current_record_fragment) do
        build(:fragment,
              display_collection: 'current_test_display_collection',
              content_partner: %w['current_content_partner current_content_partner_two],
              source_id: 'enrich_test_one')
      end

      context 'enriching an existing record' do
        let(:payload) do
          {
            'priority' => -1,
            'source_id' => 'enrich_test_one',
            'requirements' => { 'enrich_url' => 'https://www.digitalnz.org/records/replace_this' },
            'subject' =>
              ['there should only be one of these from enrich_test_one (this one was added 2019-03-07T11:18:48+13:00'],
            'job_id' => '5c804747f1676245249c5254'
          }
        end

        let!(:current_record) do
          create(:record, internal_identifier: 'end-to-end_exemplar_TEST_record-20190306T1140',
                          fragments: [current_record_fragment])
        end

        let(:record) { described_class.new(payload, false, current_record.id).call }

        it 'removes the display_collection' do
          expect(record.display_collection).to eq nil
        end

        it 'removes the content_partner' do
          expect(record.content_partner).to eq []
        end
      end

      context 'Adding a new fragment to an existing record' do
        let(:payload) do
          {
            'priority' => -1,
            'source_id' => 'new_fragment_source',
            'requirements' => { 'enrich_url' => 'https://www.digitalnz.org/records/replace_this' },
            'subject' => ['test subject'],
            'job_id' => '5c804747f1676245249c5254'
          }
        end

        let!(:current_record) do
          create(:record, internal_identifier: 'end-to-end_exemplar_TEST_record-20190306T1140',
                          fragments: [current_record_fragment])
        end

        let(:record) { described_class.new(payload, false, current_record.id).call }

        it 'creates a new fragment' do
          expect(record.fragments.count).to eq 2
        end

        it 'sets the subject' do
          expect(record.fragments.last.subject).to eq ['test subject']
        end
      end
    end
  end
end
