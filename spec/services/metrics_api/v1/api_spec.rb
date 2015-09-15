module MetricsApi
  module V1
    describe Api do
      let!(:daily_item_metric){create(:daily_item_metric)}
      let(:api) do
        Api.new({
          start_date: @start_date, 
          end_date: @end_date, 
          metrics: "usage,display_collection"
        })
      end

      before do
        @start_date = Date.current
        @end_date = Date.current

        5.times.map{create(:usage_metrics)}
      end
      
      it 'responds with JSON ready to send to the API' do
        expect(api.call).to match_response_schema('metrics/response')
      end

      it 'returns a 404 exception object if passed invalid dates' do
        @start_date = Date.current - 100.days
        @end_date = Date.current - 99.days

        response = api.call

        expect(response[:exception][:status]).to eq(404)
        expect(response[:exception][:message]).to be_present
      end
    end
  end
end
