# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  class TestSerializer < SupplejackApi::BaseSerializer
    attribute :id

    attribute :terms_and_conditions do
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    end
  end
end

module SupplejackApi
  describe TestSerializer do
    let(:record) { FactoryBot.create(:record_with_fragment) }
    let(:serialized_record) { described_class.new(record).as_json }

    it 'has id' do
      expect(serialized_record[:id]).to eq record.id
    end

    it 'has terms_and_conditions' do
      expect(serialized_record[:terms_and_conditions]).to eq 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
    end
  end
end
