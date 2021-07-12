# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe StoryItemSerializer do
    let(:item) { create(:story_item) }
    let(:response) { described_class.new(item).as_json }

    it 'has id' do
      expect(response[:id]).to eq item.id
    end

    it 'has position' do
      expect(response[:position]).to eq item.position
    end

    it 'has type' do
      expect(response[:type]).to eq item.type
    end

    it 'has sub_type' do
      expect(response[:sub_type]).to eq item.sub_type
    end

    it 'has record_id' do
      expect(response[:record_id]).to eq item.record_id
    end
  end
end
