# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::Harvester::ActivitySerializer do
  let(:activity) { create(:activity) }
  let(:serializer) { described_class.new(activity).as_json }

  describe '#attributes' do
    it 'renders :created_at' do
      expect(serializer).to have_key :created_at
    end

    it 'renders :updated_at' do
      expect(serializer).to have_key :updated_at
    end

    it 'renders :date' do
      expect(serializer).to have_key :date
    end

    it 'renders :user_sets' do
      expect(serializer).to have_key :user_sets
    end

    it 'renders :search' do
      expect(serializer).to have_key :search
    end

    it 'renders :records' do
      expect(serializer).to have_key :records
    end

    it 'renders :source_clicks' do
      expect(serializer).to have_key :source_clicks
    end

    it 'renders :total' do
      expect(serializer).to have_key :total
    end
  end
end
