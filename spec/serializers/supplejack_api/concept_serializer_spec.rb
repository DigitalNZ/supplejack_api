# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe ConceptSerializer do
    before { allow(ConceptSchema).to receive(:roles) { double(:developer).as_null_object } }

    def serializer(options={}, attributes={})
      concept_fields = Concept.fields.keys
      concept_attributes = Hash[attributes.map {|k, v| [k, v] if concept_fields.include?(k.to_s)}.compact]
      attributes.delete_if {|k, v| concept_fields.include?(k.to_s) }

      @concept = FactoryGirl.build(:concept, concept_attributes)
      @serializer = ConceptSerializer.new(@concept, options)
    end

    describe '#include_individual_fields!' do
      before { @hash = {} }

      it 'merges in the hash the requested fields' do
        s = serializer({ fields: [:name] }, { name: 'McCahon' })
        s.include_individual_fields!(@hash)
        expect(@hash).to eq({ name: 'McCahon' })
      end
    end

    describe '#build_context' do
      let(:s) { serializer() }
      let(:fields) { [:name, :prefLabel, :dateOfBirth] }

      it 'builds inline context' do
        context = {
                    :skos => "http://www.w3.org/2004/02/skos/core#",
                    :foaf => "http://xmlns.com/foaf/0.1/",
                    :rdaGr2 => "http://rdvocab.info/ElementsGr2/",
                    :name => {
                        "@id" => "foaf:name"
                    },
                    :prefLabel => {
                        "@id" => "skos:prefLabel"
                    },
                    :dateOfBirth => {
                        "@id" => "rdaGr2:dateOfBirth"
                    }
                }
        expect(s.build_context(fields)).to eq context
      end
    end

    describe '#include_context_fields!' do
      before { 
        @hash = {"@context" => {}, name: "McCahon"}
      }

      it 'include inline context in concept' do
        s = serializer({ inline_context: "true", domain: "http://localhost" })
        s.include_context_fields!(@hash)
        concept = {"@context"=>{:foaf=>"http://xmlns.com/foaf/0.1/", :name=>{"@id"=>"foaf:name"}}, :name=>"McCahon"}
        expect(@hash).to eq concept
      end

      it 'show context document url' do
        s = serializer({ domain: "http://localhost" })
        s.include_context_fields!(@hash)
        concept = {"@context"=>"http://localhost/schema", :name=>"McCahon"}
        expect(@hash).to eq concept
      end
    end
  end
end
