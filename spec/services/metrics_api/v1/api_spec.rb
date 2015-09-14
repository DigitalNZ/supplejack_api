module MetricsApi
  module V1
    describe Api, focus: true do
      let(:daily_item_metric){create(:daily_item_metric)}
      let(:usage_metrics){5.times.map{create(:usage_metrics)}}
      let(:api) do
        Api.new({
          start_date: Date.current, 
          end_date: Date.current, 
          metrics: "usage,display_collection"
        })
      end
      
      it 'responds with JSON ready to send to the API' do
        expect(api.call).to match_response_schema('metrics/response')
      end
    end
  end
end
