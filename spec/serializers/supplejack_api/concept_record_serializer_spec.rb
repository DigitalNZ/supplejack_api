# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe ConceptRecordSerializer do
    let(:record) { FactoryBot.create(:record) }
    let(:serialized_concept_record) { ConceptRecordSerializer.new(record).as_json }

    describe 'attributes' do
      it 'includes the @id' do
        expect(serialized_concept_record).to have_key '@id'
      end

      it 'includes the @type' do
        expect(serialized_concept_record).to have_key '@type'
      end

      it 'includes the :title' do
        expect(serialized_concept_record).to have_key :title
      end

      it 'includes the :description' do
        expect(serialized_concept_record).to have_key :description
      end

      it 'includes the :date' do
        expect(serialized_concept_record).to have_key :date
      end

      it 'includes the :display_content_partner' do
        expect(serialized_concept_record).to have_key :display_content_partner
      end

      it 'includes the :display_collection' do
        expect(serialized_concept_record).to have_key :display_collection
      end

      it 'includes the :thumbnail_url' do
        expect(serialized_concept_record).to have_key :thumbnail_url
      end
    end
  end
end
