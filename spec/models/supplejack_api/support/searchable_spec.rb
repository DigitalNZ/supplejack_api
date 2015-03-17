# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  module Support
    describe Searchable do
      let(:record) { FactoryGirl.create(:record, record_id: 1234) }
      let(:fragment) { record.fragments.create({nz_citizen: false }) }
    
      before do
        allow(RecordSchema).to receive(:fields) do
          {
            name: double(:field, name: :name, type: :string, search_as: [:filter]).as_null_object,
            age: double(:field, name: :age, type: :integer, search_as: [:filter]).as_null_object,
            birth_date: double(:field, name: :birth_date, type: :datetime, search_as: [:filter]).as_null_object,
            nz_citizen: double(:field, name: :nz_citizen, type: :boolean, search_as: [:filter]).as_null_object,
            email: double(:field, name: :email, type: :string, multi_value: true, search_as: [:filter]).as_null_object,
            address: double(:field, name: :address, type: :string, search_as: [:filter], solr_name: :new_address).as_null_object,
            occupation: double(:field, name: :occupation, type: :string, search_as: [:fulltext]).as_null_object,
            birth_place: double(:field, name: :birth_place, type: :string, search_as: [:fulltext], search_boost: 10).as_null_object,
            short_description: double(:field, name: :short_description, multi_value: true, type: :string, search_as: [:fulltext, :filter], search_boost: 2).as_null_object
          }
        end
      end

      describe 'build_sunspot_schema' do
        let(:builder) { double(:search_builder).as_null_object }
        let(:search_value) { double(:proc) }
    
        after do
          Record.build_sunspot_schema(builder)
        end
    
        it 'defines a single value string field' do
          expect(builder).to receive(:string).with(:name, {})
        end
    
        it 'defines a single value integer field' do
          expect(builder).to receive(:integer).with(:age, {})
        end
    
        it 'defines a single value time field' do
          expect(builder).to receive(:time).with(:birth_date, {})
        end
    
        it 'defines a single value boolean field' do
          expect(builder).to receive(:boolean).with(:nz_citizen, {})
        end
    
        it 'defines a multivalue field' do
          expect(builder).to receive(:string).with(:email, {multiple: true})
        end
    
        it 'defines a field with a different name' do
          expect(builder).to receive(:string).with(:address, {as: :new_address})
        end
    
        it 'defines a full text field' do
          expect(builder).to receive(:text).with(:occupation, {})
        end
    
        it 'defines a full text field with boost' do
          expect(builder).to receive(:text).with(:birth_place, {boost: 10})
        end   
    
        it 'defines a field with fulltext and filter, and lots of options' do
          expect(builder).to receive(:text).with(:short_description, {boost: 2})
          expect(builder).to receive(:string).with(:short_description, {multiple: true})
        end
      end

      describe 'valid_facets' do
        it 'returns all fields with search_as filter' do
          expect(Record.valid_facets).to eq [:name, :age, :birth_date, :nz_citizen, :email, :address, :short_description]
        end      
      end
    end
  end
end
