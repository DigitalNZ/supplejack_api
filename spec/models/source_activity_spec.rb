# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe SourceActivity do
    describe '#increment' do
      context 'SourceActivity doesn\'t exist' do
        it 'creates a SourceActivity with source activity of 1' do
          SupplejackApi::SourceActivity.increment
          expect(SupplejackApi::SourceActivity.get_source_clicks).to eq 1
        end
      end

      context 'SourceActivity exists' do
        before { SupplejackApi::SourceActivity.create(source_clicks: 12) }

        it 'increments source activity' do
          SupplejackApi::SourceActivity.increment

          expect(SupplejackApi::SourceActivity.get_source_clicks).to eq 13
        end
      end
    end

    describe '#get_source_clicks' do
      it 'returns the source_clicks count if SourceActive exists' do
        SupplejackApi::SourceActivity.increment

        expect(SupplejackApi::SourceActivity.get_source_clicks).to eq 1
      end

      it 'returns nil if no SourceActivity' do
        expect(SupplejackApi::SourceActivity.get_source_clicks).to be_nil
      end
    end

    describe '#reset' do
      it 'deletes first instance of SourceActivity if exists' do
        SupplejackApi::SourceActivity.increment
        SupplejackApi::SourceActivity.reset

        expect(SupplejackApi::SourceActivity.count).to be 0
      end

      it 'handles no source activity' do
        2.times { SupplejackApi::SourceActivity.reset }
      end
    end
  end
end
