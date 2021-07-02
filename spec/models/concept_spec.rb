# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe Concept do
    let(:concept) { create(:concept) }
    let(:record) { create(:record) }

    subject { concept }

    describe 'fields' do
      context '.model fields' do
        %w[concept_type concept_id].each do |field|
          it "responds to #{field} field" do
            expect(concept.respond_to?(field)).to be_truthy
          end
        end
      end

      context '.schema fields' do
        ConceptSchema.model_fields.each do |name, field|
          it "sets the #{name} field from the schema" do
            expect(concept.respond_to?(name)).to be_truthy unless field.try(:store) == false
          end
        end
      end
    end

    # describe '#custom_find' do
    #   before(:each) do
    #     @concept = FactoryBot.create(:concept, concept_id: 54321)
    #   end

    #   it 'should search for a concept via its concept_id' do
    #     expect(Concept.custom_find(54321)).to eq(@concept)
    #   end

    #   it 'should search for a concept via its ObjectId (MongoDB auto assigned id)' do
    #     expect(Concept.custom_find(@concept.id)).to eq(@concept)
    #   end

    #   it 'should raise a error when a concept is not found' do
    #     expect { Concept.custom_find(111) }.to raise_error(Mongoid::Errors::DocumentNotFound)
    #   end
    # end

    describe '#build_context' do
      let(:fields) { %i[name prefLabel dateOfBirth] }

      it 'builds inline context' do
        context = {
          skos: 'http://www.w3.org/2004/02/skos/core#',
          foaf: 'http://xmlns.com/foaf/0.1/',
          rdaGr2: 'http://rdvocab.info/ElementsGr2/',
          dcterms: 'http://purl.org/dc/terms/',
          concept_id: {
            '@id' => 'dcterms:identifier'
          },
          name: {
            '@id' => 'foaf:name'
          },
          prefLabel: {
            '@id' => 'skos:prefLabel'
          },
          dateOfBirth: {
            '@id' => 'rdaGr2:dateOfBirth'
          }
        }

        expect(Concept.build_context(fields)).to eq context
      end
    end

    describe '#records' do
      it 'returns the records' do
        record.concepts << concept
        expect(concept.records).to eq [record]
      end
    end

    describe '#edm_type' do
      it 'returns the type of the concept' do
        expect(concept.edm_type).to eq 'agents'
      end
    end

    describe '#site_id' do
      it 'returns the site_id of the concept' do
        expect(concept.site_id).to eq "#{ENV['CONCEPT_HTTP_HOST']}/concepts/#{concept.concept_id}"
      end
    end

    describe '#context' do
      it 'returns the context of the concept' do
        expect(concept.context).to eq "#{ENV['HTTP_HOST']}/schema"
      end
    end

    #   it "shouldn't call find when the mongo id is invalid" do
    #     expect(Concept).to_not receive(:find)
    #     expect { Concept.custom_find('1234567abc') }.to raise_error(Mongoid::Errors::DocumentNotFound)
    #   end

    #   context 'restricting inactive concepts' do
    #     it 'finds only active concepts' do
    #       @concept.update_attribute(:status, 'deleted')
    #       @concept.reload
    #       expect { Concept.custom_find(54321) }.to raise_error(Mongoid::Errors::DocumentNotFound)
    #     end

    #     it 'finds also inactive records when :status => :all' do
    #       @concept.update_attribute(:status, 'deleted')
    #       @concept.reload
    #       expect(Concept.custom_find(54321, nil, {status: :all})).to eq @concept
    #     end

    #     it "doesn't break with nil options" do
    #       expect(Concept.custom_find(54321, nil, nil)).to eq @concept
    #     end
    #   end
    # end

    # describe '#active?' do
    # 	before { @record = build(:record) }

    #   it 'returns true when state is active' do
    #     @record.status = 'active'
    #     expect(@record.active?).to be_truthy
    #   end

    #   it 'returns false when state is deleted' do
    #     @record.status = 'deleted'
    #     expect(@record.active?).to be_falsey
    #   end
    # end

    # describe '#should_index?' do
    #   before { @record = build(:record) }

    #   it 'returns false when active? is false' do
    #     allow(@record).to receive(:active?) { false }
    #     expect(@record.should_index?).to be_falsey
    #   end

    #   it 'returns true when active? is true' do
    #     allow(@record).to receive(:active?) { true }
    #     expect(@record.should_index?).to be_truthy
    #   end
    # end
  end
end
