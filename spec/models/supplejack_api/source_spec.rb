# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe Source do
    let!(:source) { FactoryGirl.create(:source, status: 'active') }
  
    describe '#suppressed' do
      let!(:suppressed_source) { FactoryGirl.create(:source, status: 'suppressed') }
  
      it 'should return all the suppressed sources' do
        expect(Source.suppressed.to_a).to eq [suppressed_source]
      end
    end

    describe '#random_records' do
      let(:mongo_query_where) { Mongoid::Criteria.new(Record) }
      let(:mongo_query_sort) { Mongoid::Criteria.new(Record) }

      before do
        allow(Record).to receive(:where) { mongo_query_where }
        allow(mongo_query_where).to receive(:sort) { mongo_query_sort }
      end

      it 'should fetch records with source id of the instance' do
        expect(Record).to receive(:where).with({ "fragments.source_id" => "1234",
                                                 :status => "active"})

        source.random_records(4)
      end

      it 'should sort the records and limit it to 100' do
        expect(mongo_query_where).to receive(:sort).with({"fragments.syndication_date" => -1})
        expect(mongo_query_where).to receive(:sort).with({"fragments.syndication_date" => 1})
        expect(mongo_query_sort).to receive(:limit).with(100).twice

        source.random_records(4)
      end

      it 'should fetch random 4 records from the result' do
        expect_any_instance_of(Array).to receive(:sample).with(4)

        source.random_records(4)
      end      
    end
  end
end