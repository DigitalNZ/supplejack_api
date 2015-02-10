# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe SearchSerializer do
  
    def facet_row(value, count)
      double(:facet_row, value: value, count: count)
    end

    def facet_objects
      [
        double(:facet, name: :full_name ,rows: [ 
          facet_row('Nick Miller', 123), 
          facet_row('Winston Bishop', 10) 
        ]),
        double(:facet, name: :coffee ,rows: [ 
          facet_row('Dark', 3022), 
          facet_row('Mid', 104),
          facet_row('Light', 11)
        ])
      ]
    end

    before {
      @facets = facet_objects
      @search = double(:search, results: [], total: 10, per_page: 20, page: 1, facets: @facets, 
        request_url: "http://foo.com/records", collation: 'whanganui').as_null_object 
      
      # Test using RecordSearchSerializer
      @serializer = RecordSearchSerializer.new(@search)
    }

    describe '#json_facets' do
      it 'returns a hash of facets' do
        expect(@serializer.json_facets).to be_a(Hash)
      end
      
      it 'should have two facets' do
        expect(@serializer.json_facets.size).to eq(2)
      end
      
      it 'returns facets with name as key' do
        expect(@serializer.json_facets.keys).to include(:full_name, :coffee)
      end
      
      it 'returns each facet as a hash' do
        expect(@serializer.json_facets[:full_name]).to be_a(Hash)
      end
      
      it 'returns facet-values and their counts' do
        expect(@serializer.json_facets[:full_name]).to include('Nick Miller' => 123, 'Winston Bishop' => 10)
      end
    end

    describe '#xml_facets' do
      it 'returns a array of facets' do
        expect(@serializer.xml_facets).to be_a(Array)
      end
      
      it 'should have two facets' do
        expect(@serializer.xml_facets.size).to eq(2)
      end
      
      it 'includes the name of each facet' do
        facet = @serializer.xml_facets.first
        expect(facet[:name]).to eq 'full_name'
      end
      
      it 'each facet should have a array of values with name and count' do
        facet = @serializer.xml_facets.first
        expect(facet[:values]).to eq [{ name: 'Nick Miller', count: 123 }, { name: 'Winston Bishop', count: 10 }]
      end
    end
    
    describe '#to_json' do
      # it 'wraps everything in a jsonp function' do
      #   allow(@search).to receive(:jsonp) { 'SupplejackApi.function' }
      #   expect(@serializer.to_json).to match(/^SupplejackApi.function\(.*\)$/)
      # end
    end
  end

end