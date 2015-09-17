module MetricsApi
  module V3
    module Endpoints
      describe Extended do
        let(:extended) do
          Extended.new({
            facets: @facets,
            start_date: @start_date,
            end_date: @end_date,
            metrics: @metrics
          })
        end

        before do
          @facets = 'dc1,dc2'
          @start_date = Date.current
          @end_date = Date.current
          @metrics = 'view,record'
        end

        describe "#call" do
          it 'retrieves a range of metrics' do
            create(:daily_item_metric)
            create(:usage_metrics, record_field_value: 'dc1')
            create(:usage_metrics, record_field_value: 'dc2')

            result = extended.call

            expect(result.length).to eq(2)
            expect(Date.parse(result.first[:day])).to eq(Date.current)
            expect(result.first[:record]).to be_present
            expect(result.first[:view]).to be_present
          end
        end
      end
    end
  end
end
