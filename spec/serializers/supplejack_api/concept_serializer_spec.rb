# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe ConceptSerializer do
    let(:concept) { create(:concept) }
    let(:serialized_concept) { ConceptSerializer.new(concept).as_json }
    let(:serialized_concept_with_inline_context) { ConceptSerializer.new(concept, inline_context: true).as_json }

    it 'has @context' do
      expect(serialized_concept).to have_key '@context'
    end

    it 'has @type' do
      expect(serialized_concept).to have_key '@type'
    end

    it 'has @id' do
      expect(serialized_concept).to have_key '@id'
    end

    it 'has :concept_id' do
      expect(serialized_concept).to have_key :concept_id
    end

    it 'has @reverse' do
      expect(serialized_concept).to have_key '@reverse'
    end

    describe 'inline_context' do
      it 'has :foaf information' do
        expect(serialized_concept_with_inline_context['@context'][:foaf]).to eq 'http://xmlns.com/foaf/0.1/'
      end

      it 'has :dc information' do
        expect(serialized_concept_with_inline_context['@context'][:dc]).to eq 'http://purl.org/dc/elements/1.1/'
      end

      it 'has :edm information' do
        expect(serialized_concept_with_inline_context['@context'][:edm]).to eq 'http://www.europeana.eu/schemas/edm/'
      end

      it 'has :dcterms information' do
        expect(serialized_concept_with_inline_context['@context'][:dcterms]).to eq 'http://purl.org/dc/terms/'
      end

      it 'has :concept_id' do
        expect(serialized_concept_with_inline_context['@context'][:concept_id]).to eq '@id' => 'dcterms:identifier'
      end

      it 'has :name' do
        expect(serialized_concept_with_inline_context['@context'][:name]).to eq '@id' => 'foaf:name'
      end

      it 'has :type' do
        expect(serialized_concept_with_inline_context['@context'][:type]).to eq '@id' => ':type'
      end

      it 'has :date' do
        expect(serialized_concept_with_inline_context['@context'][:date]).to eq '@id' => 'dc:date'
      end

      it 'has :description' do
        expect(serialized_concept_with_inline_context['@context'][:description]).to eq '@id' => 'dc:description'
      end

      it 'has :agents' do
        expect(serialized_concept_with_inline_context['@context'][:agents]).to eq '@id' => 'edm:agents'
      end

      it 'has :source_authority' do
        expect(serialized_concept_with_inline_context['@context'][:source_authority])
          .to eq '@id' => 'foaf:source_authority'
      end
    end

    describe 'it renders attributes based on your schema' do
      ConceptSchema.model_fields.each do |name, definition|
        next if definition.store == false

        it "has #{name} field" do
          expect(serialized_concept).to have_key name
        end
      end
    end
  end
end
