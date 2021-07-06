# frozen_string_literal: true

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
      it 'should fetch records with source id of the instance' do
        records = source.random_records(4)
        records.each do |record|
          expect(record.source_id).to_eq '1234'
        end
      end

      it 'should fetch random 4 records from the result' do
        expect_any_instance_of(Array).to receive(:sample).with(4)

        source.random_records(4)
      end
    end
  end
end
