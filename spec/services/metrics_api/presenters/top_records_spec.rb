# frozen_string_literal: true

require 'spec_helper'
require 'json'

module MetricsApi
  module Presenters
    describe TopRecords do
      let(:presenter) { TopRecords.new(@model) }
      before { @model = create(:top_collection_metric, results: { 1 => 2, 3 => 4 }) }

      it 'presents them' do
        json = presenter.to_json

        expect(json.length).to eq(1)
        expect(json['appeared_in_searches']).to eq({ 1 => 2, 3 => 4 })
      end
    end
  end
end
