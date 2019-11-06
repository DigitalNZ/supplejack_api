require 'spec_helper'

module MetricsApi
  module V3
    module Endpoints
      describe Global do
        let(:global) {Global.new({})}

        describe "#call" do
          it "returns an array of hashes representing the DailyMetrics for the supplied date range" do
            create(:daily_metrics, date: Time.now.utc.to_date, total_public_sets: 10)

            expect(global.call).to eq([{
              day: Time.now.utc.to_date,
              total_public_sets: 10
            }])
          end
        end
      end
    end
  end
end
