# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe ConceptRecordSerializer do
    let(:record) { SupplejackApi::Record.new(title: 'Wellington', description: 'New Zealand', date: '2015-06-05', 
      display_content_partner: 'Television New Zealand', display_collection: 'TVNZ', thumbnail_url: 'http://example.com') }
    let(:serializer) { ConceptRecordSerializer.new(record) }
  
   it 'includes the basic record information' do
      allow(record).to receive(:id) { 'abc' }
      allow(record).to receive(:record_id) { '123' }
      json = serializer.as_json[:concept_record]

      expect(json['@id']).to eq 'http://test.host/records/123'
      expect(json['title']).to eq record.title
      expect(json['description']).to eq record.description
      expect(json['date']).to eq record.date
      expect(json['display_content_partner']).to eq record.display_content_partner
      expect(json['display_collection']).to eq record.display_collection
      expect(json['thumbnail_url']).to eq record.thumbnail_url
    end
  end
end
