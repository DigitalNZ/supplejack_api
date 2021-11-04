# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::Harvester::ActivitySerializer do
  let(:activity) { create(:activity) }
  let(:serializer) { described_class.new(activity).as_json }

  describe '#attributes' do
    it 'has :created_at' do
      expect(serializer[:created_at]).to eq activity.created_at
    end

    it 'has :updated_at' do
      expect(serializer[:updated_at]).to eq activity.updated_at
    end

    it 'has :date' do
      expect(serializer[:date]).to eq activity.date
    end

    it 'has :user_sets' do
      expect(serializer[:user_sets]).to eq activity.user_sets
    end

    it 'has :search' do
      expect(serializer[:search]).to eq activity.search
    end

    it 'has :records' do
      expect(serializer[:records]).to eq activity.records
    end

    it 'has :source_clicks' do
      expect(serializer[:source_clicks]).to eq activity.source_clicks
    end

    it 'has :total' do
      expect(serializer[:total]).to eq activity.total
    end
  end
end
