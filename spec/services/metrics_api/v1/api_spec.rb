module MetricsApi
  module V1
    describe Api, focus: true do
      let(:daily_item_metric){create(:daily_item_metric)}
      let(:usage_metrics){5.times.map{create(:usage_metrics)}}
      let(:api){Api.new(Date.current, Date.current, ['usage', 'display_collection'])}
      
      it 'responds with JSON ready to send to the API' do
        expect(api.call).to match_response_schema('metrics/response')
      end
    end
  end
end
