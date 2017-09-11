# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe RecordSerializer do
    let(:record) { FactoryGirl.create(:record_with_fragment) }
    let(:serialized_record) { described_class.new(record).as_json}

    it 'renders the id' do
      expect(serialized_record).to have_key :id
    end

    describe 'it renders attributes based on your schema' do
      RecordSchema.fields.each do |name, definition|
        next if definition.store == false
        it "renders the #{name} field" do
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

    it 'uses a provided date format' do
      expect(serialized_record[:created_at]).to eq record.created_at.strftime("%y/%d/%m")
    end

    it 'returns a value from the record' do
      expect(serialized_record[:title]).to eq record.title
    end

    it 'returns multi values correctly' do
      expect(serialized_record[:children]).to eq ['Sally Doe', 'James Doe']
    end

    # The purpose of these fields is so that if a user has made a search and clicked on a landing page for that record,
    # we are able to go next and previous from the show page of that record between the search results.
    # This saves us from attempting to store the search results on the client app
    # The url looks like this /records/:record_jd.json?api_key=:api_key&search[text]=:search_term&text=:search_term

    it 'includes :next_record when it is present' do
      record.next_record = 2
      expect(serialized_record[:next_record]).to eq 2
    end

    it 'includes :previous_record when it is present' do
      record.previous_record = 2
      expect(serialized_record[:previous_record]).to eq 2
    end

    it 'includes :next_page when it is provided' do
      record.next_page = 2
      expect(serialized_record[:next_page]).to eq 2
    end

    it 'includes :previous_page when it is provided' do
      record.previous_page = 2
      expect(serialized_record[:previous_page]).to eq 2
    end

    it 'does not include :next_record when it is null' do
      record.next_record = nil
      expect(serialized_record).to_not have_key(:next_record)
    end

    it 'does not include :previous_record when it is null' do
      record.previous_record = nil
      expect(serialized_record).to_not have_key(:previous_record)
    end

    it 'does not include :next_page when it is null' do
      record.next_page = nil
      expect(serialized_record).to_not have_key(:next_page)
    end

    it 'does not include :previous_page when it is null' do
      record.previous_page = nil
      expect(serialized_record).to_not have_key(:previous_page)
    end
  end
end
