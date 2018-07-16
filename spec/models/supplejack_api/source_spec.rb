

require 'spec_helper'

module SupplejackApi
  describe Source do
    let!(:source) { FactoryBot.create(:source, status: 'active') }

    describe '#suppressed' do
      let!(:suppressed_source) { FactoryBot.create(:source, status: 'suppressed') }

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

    describe '#hints' do
      context 'has mongo indexes' do
        it 'returns a hash of index hints ' do
          indexes = [{'name'=>'fragments.job_id_1_status_1'}]
          SupplejackApi.config.record_class.stub_chain(:collection, :indexes, :as_json).and_return indexes

          expect(source.hints).to eq({ 'fragments.job_id' => 1, 'status' => 1 })
        end
      end

      context 'has no mongo indexes' do
        it 'returns an empty hash ' do
          expect(source.hints).to eq({})
        end
      end
    end
  end
end
