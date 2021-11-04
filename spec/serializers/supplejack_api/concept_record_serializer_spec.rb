# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe ConceptRecordSerializer do
    let(:record) { create(:record) }
    let(:serialized_concept_record) { ConceptRecordSerializer.new(record).as_json }

    describe 'attributes' do
      it 'has @id' do
        expect(serialized_concept_record).to have_key '@id'
      end

      it 'has @type' do
        expect(serialized_concept_record).to have_key '@type'
      end

      it 'has :title' do
        expect(serialized_concept_record[:title]).to eq record.title
      end

      it 'has :description' do
        expect(serialized_concept_record[:description]).to eq record.description
      end

      it 'has :date' do
        expect(serialized_concept_record[:date]).to eq record.date
      end

      it 'has :display_content_partner' do
        expect(serialized_concept_record[:display_content_partner]).to eq record.display_content_partner
      end

      it 'has :display_collection' do
        expect(serialized_concept_record[:display_collection]).to eq record.display_collection
      end

      it 'has :thumbnail_url' do
        expect(serialized_concept_record[:thumbnail_url]).to eq record.thumbnail_url
      end
    end
  end
end
