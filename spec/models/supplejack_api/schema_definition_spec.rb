# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe SchemaDefinition do

    class ExampleSchema
      include SchemaDefinition

      namespace :dc, url: 'http://purl.org/dc/elements/1.1/'

      string :title,                  search_boost: 10, search_as: [:fulltext], namespace: :dc, namespace_field: :creator
      string :display_collection
      string :primary_collection,     multi_value: true,  search_as: [:filter]
      boolean :is_natlib_record,                          search_as: [:filter]
      integer :year do
        multi_value true
        store false
        search_as [:filter]
        search_value do |record|
          record.date.map { |date| Date.parse(date).year rescue nil}.compact if record.date
        end
      end
      datetime :syndication_date,                         search_as: [:filter]
      string :text, solr_name: :text
      string :display_date, date_format: '%y/%d/%m'
      string :dnz_type, default_value: 'Unknown'

      latlon(:lat_lng) do
        search_as [:filter]
        multi_value true
        search_value do |record|
          record.locations.keep_if do |l|
            (l.lat.present? and l.lng.present?) ? Sunspot::Util::Coordinates.new(l.lat, l.lng) : Sunspot::Util::Coordinates.new(0, 0)
          end
        end
      end

      mongo_index :year, fields: [{year: 1}], index_options: [{background:true}]
      mongo_index :title_is_natlib_record, fields: [{title: 1, is_natlib_record: 1}]

      group :default do
        fields [
          :title,
          :year
        ]
      end

      group :verbose do
        includes [:default]
        fields [
          :locations
        ]
      end

      group :everything do
        includes [:default, :verbose]
        fields [
          :id
        ]
      end

      role :admin
      role :user

      role :developer do
        default true
        field_restrictions (
          {
            creator: { 'John Smith' => ['attachments', 'location'] },
            thumbnail_url: { /^http:\/\/secret/ => ['thumbnail_url'] }
          }
        )
        record_restrictions (
          {
            is_catalog_record: true
          }
        )
      end

      model_field :name, field_options: { type: String }, validation: { presence: true }, index_fields: { name: 1, address: 1 }, index_options: { background: true }, store: false
    end


    describe '#fields' do

      it 'describes title' do
        expect(ExampleSchema.fields[:title].name).to eq :title
        expect(ExampleSchema.fields[:title].type).to eq :string
        expect(ExampleSchema.fields[:title].search_boost).to eq 10
        expect(ExampleSchema.fields[:title].search_as).to eq [:fulltext]
        expect(ExampleSchema.fields[:title].namespace).to eq :dc
        expect(ExampleSchema.fields[:title].namespace_field).to eq :creator
      end

      it 'deiscribe dnz_type' do
        expect(ExampleSchema.fields[:dnz_type].name).to eq :dnz_type
        expect(ExampleSchema.fields[:dnz_type].default_value).to eq 'Unknown'
      end

      it 'deiscribe display_date' do
        expect(ExampleSchema.fields[:display_date].name).to eq :display_date
        expect(ExampleSchema.fields[:display_date].date_format).to eq '%y/%d/%m'
      end

      it 'describes display_collection' do
        expect(ExampleSchema.fields[:display_collection].name).to eq :display_collection
        expect(ExampleSchema.fields[:display_collection].type).to eq :string
      end

      it 'describes primary_collection' do
        expect(ExampleSchema.fields[:primary_collection].name).to eq :primary_collection
        expect(ExampleSchema.fields[:primary_collection].type).to eq :string
        expect(ExampleSchema.fields[:primary_collection].multi_value).to be_truthy
        expect(ExampleSchema.fields[:primary_collection].search_as).to eq [:filter]
      end

      it 'describes is_natlib_record' do
        expect(ExampleSchema.fields[:is_natlib_record].name).to eq :is_natlib_record
        expect(ExampleSchema.fields[:is_natlib_record].type).to eq :boolean
      end

      it 'describes year' do
        expect(ExampleSchema.fields[:year].name).to eq :year
        expect(ExampleSchema.fields[:year].type).to eq :integer
        expect(ExampleSchema.fields[:year].multi_value).to be_truthy
        expect(ExampleSchema.fields[:year].store).to be_falsey
        expect(ExampleSchema.fields[:year].search_as).to eq [:filter]
        expect(ExampleSchema.fields[:year].search_value).to be_a Proc
      end

      it 'describes syndication_date' do
        expect(ExampleSchema.fields[:syndication_date].name).to eq :syndication_date
        expect(ExampleSchema.fields[:syndication_date].type).to eq :datetime
        expect(ExampleSchema.fields[:syndication_date].search_as).to eq [:filter]
      end

      it 'describes text' do
        expect(ExampleSchema.fields[:text].name).to eq :text
        expect(ExampleSchema.fields[:text].type).to eq :string
        expect(ExampleSchema.fields[:text].solr_name).to eq :text
      end

      it 'describes lat_lng' do
        expect(ExampleSchema.fields[:lat_lng].name).to eq :lat_lng
        expect(ExampleSchema.fields[:lat_lng].type).to eq :latlon
        expect(ExampleSchema.fields[:lat_lng].search_as).to eq [:filter]
        expect(ExampleSchema.fields[:lat_lng].multi_value).to be_truthy
      end      

      context 'namespace field' do
        it 'returns the namespace field' do
          expect(ExampleSchema.fields[:title].namespace_field).to eq :creator
        end

        it 'returns the field name if a namespace_field is not defined' do
          expect(ExampleSchema.fields[:display_collection].namespace_field).to eq :display_collection
        end
      end
    end

    describe '#groups' do
      it 'returns all the groups defined' do
        expect(ExampleSchema.groups.keys).to eq([:default, :verbose, :everything])
      end

      describe '#fields' do
        it 'returns a list of fields in a group' do
          expect(ExampleSchema.groups[:default].fields).to eq([:title, :year])
        end
      end

      context 'includes groups' do
        it 'includes another group of fields' do
          expect(ExampleSchema.groups[:verbose].fields).to eq([:title, :year, :locations])
        end

        it 'includes multiple groups of fields' do
          expect(ExampleSchema.groups[:everything].fields).to eq([:title, :year, :locations, :id])
        end
      end
    end

    describe '#roles' do
      it 'should all the roles defined' do
        expect(ExampleSchema.roles.keys).to eq([:admin, :user, :developer])
      end

      context 'field_restrictions' do
        let(:restrictions) { ExampleSchema.roles[:developer].field_restrictions }

        it 'should create a restriction on the attachments and location fields if the creator is John Smith' do
          expect(restrictions[:creator]).to eq( {'John Smith' => ['attachments', 'location']} )
        end

        it 'should create a restriction on the thumbnail_url field if contains a value (matches regex)' do
          expect(restrictions[:thumbnail_url]).to eq( {/^http:\/\/secret/ => ['thumbnail_url']} )
        end
      end

      context 'record_restrictions' do
        let(:restrictions) { ExampleSchema.roles[:developer].record_restrictions }

        it 'should create a restriction on records where is_catalog_record is true' do
          expect(restrictions[:is_catalog_record]).to be_truthy
        end

        it 'should not create a restriction if none are set' do
          expect(ExampleSchema.roles[:admin].record_restrictions).to be_nil
        end
      end

      context 'default' do
        it 'should set the developer role as default' do
          expect(ExampleSchema.default_role.name).to eq :developer
        end

        it 'should not set the admin role as default' do
          expect(ExampleSchema.default_role.name).to_not eq :admin
        end
      end
    end

    describe '#namespaces' do
      it 'should return all the defined namespaces' do
        expect(ExampleSchema.namespaces.keys).to eq([:dc])
      end
    end

    describe '#mongo_indexes' do
      it 'returns all the mongo indexes that are defined' do
        expect(ExampleSchema.mongo_indexes.keys).to eq [:year, :title_is_natlib_record]
      end

      it 'returns the fields for a given index' do
        expect(ExampleSchema.mongo_indexes[:year].fields).to eq [{year: 1}]
      end

      it 'returns the index_options for an index' do
        expect(ExampleSchema.mongo_indexes[:year].index_options).to eq [{background:true}]
      end
    end

    describe '#model_field' do
      it 'returns all the model fields that are defined' do
        expect(ExampleSchema.model_fields.keys).to eq [:name]  
      end

      it 'returns the field_options for a model' do
        expect(ExampleSchema.model_fields[:name].field_options).to include({ type: String })
      end

      it 'returns the validation for a model' do
        expect(ExampleSchema.model_fields[:name].validation).to include({ presence: true })
      end

      it 'returns the index_fields for a model' do
        expect(ExampleSchema.model_fields[:name].index_fields).to include({ name: 1 })
      end

      it 'returns the index_options for a model' do
        expect(ExampleSchema.model_fields[:name].index_options).to include({ background: true })
      end
    end
  end
end
