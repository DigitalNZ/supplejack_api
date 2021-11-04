# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe MltSerializer do
    let(:record) { create(:record_with_fragment) }
    let(:serialized_record) { described_class.new(record).as_json }

    it 'has id' do
      expect(serialized_record).to have_key :id
    end

    describe 'schema attributes' do
      RecordSchema.fields.each do |name, definition|
        next if definition.store == false

        it "has #{name} field" do
          expect(serialized_record).to have_key name
        end
      end
    end

    it 'allows a field to be overriden by passing a block and setting store to false on the schema' do
      expect(serialized_record[:block_example]).to eq 'Value of the block'
    end

    it 'falls back to the provided default value if its value is nil' do
      expect(serialized_record[:default_example]).to eq 'Default value'
    end

    it 'returns a value from the record' do
      expect(serialized_record[:title]).to eq record.title
    end

    it 'returns multi values correctly' do
      expect(serialized_record[:children]).to eq ['Sally Doe', 'James Doe']
    end
  end
end
