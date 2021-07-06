# frozen_string_literal: true

require 'spec_helper'

module MetricsApi
  module V3
    describe Api do
      let!(:daily_item_metric) { create(:daily_item_metric) }

      let(:api) do
        Api.new(
          { start_date: @start_date,
            end_date: @end_date,
            metrics: 'usage,display_collection' }
        )
      end

      before do
        @start_date = Time.now.utc.to_date
        @end_date = Time.now.utc.to_date

        5.times.map { create(:usage_metrics) }
      end
    end
  end
end
