# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe ConceptSerializer do
    # before { allow(ConceptSchema).to receive(:roles) { double(:developer).as_null_object } }

    # def serializer(options={}, attributes={})
    #   concept_fields = Concept.fields.keys
    #   concept_attributes = Hash[attributes.map {|k, v| [k, v] if concept_fields.include?(k.to_s)}.compact]
    #   attributes.delete_if {|k, v| concept_fields.include?(k.to_s) }

    #   @concept = FactoryGirl.build(:concept, concept_attributes)
    #   @concept.fragments.build(attributes)
    #   @serializer = ConceptSerializer.new(@concept, options)
    # end

    # describe '#include_individual_fields!' do
    #   before { @hash = {} }

    #   it 'merges in the hash the requested fields' do
    #     s = serializer({ fields: [:gender] }, { gender: 'female' })
    #     s.include_individual_fields!(@hash)
    #     expect(@hash).to eq({ gender: 'female' })
    #   end
    # end

    # describe '#build_context' do
    #   let(:s) { serializer() }
    #   let(:fields) { [:label, :description, :dateOfBirth] }

    #   it 'only returns namespace information for the given fields' do
    #     context = {:skos=>"http://www.w3.org/2004/02/skos/core", :label=>"skos:prefLabel", :rdaGr2=>"http://rdvocab.info/ElementsGr2/", :description=>"rdaGr2:biographicalInformation", :dateOfBirth=>"rdaGr2:dateOfBirth"}
    #     expect(s.build_context(fields)).to eq context
    #   end
    # end

  end
end
