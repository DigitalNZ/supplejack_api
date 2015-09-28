require 'spec_helper'

module MetricsApi
  module V3
    module Endpoints
      describe Root do
        let(:root) do
          Root.new({
            start_date: @start_date,
            end_date: @end_date
          })
        end

        before do
          @start_date = Date.current.strftime
          @end_date = Date.current.strftime
        end

        describe "#call" do
          before do
            3.times do |n|
              create(:daily_item_metric, day: Date.current - n.days)
            end
          end

          it 'retrieves a range of metrics' do
            @start_date = (Date.current - 2.days).strftime

            result = root.call

            3.times do |i|
              expect(Date.parse(result[i][:day])).to eq(Date.current - i.days)
            end
          end

          it 'does not retrieve metrics outside of the range' do
            result = root.call

            expect(result.length).to eq(1)
          end

          it 'responds with Dates not DateTimes' do
            result = root.call

            expect(result.first[:day]).to eq(Date.current.strftime)
          end
        end
      end
    end
  end
end
