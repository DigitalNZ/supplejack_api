require 'spec_helper'

module SupplejackApi
  describe MetricsApiController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    def build_models
      5.times do |n|
        create(:daily_item_metric, date: Date.current - n.days)
        create(:faceted_metrics, date: Date.current - n.days)
        create(:usage_metrics, created_at: Date.current - n.days)
      end
    end

    describe 'GET root' do
      context "succesful requests" do
        after do
          expect(response.body).to match_response_schema('metrics/extended_response')
        end

        it 'retrieves a range of extended metrics, filtered against the facet parameter' do
          create(:faceted_metrics, name: 'dc1', date: Date.yesterday)
          create(:faceted_metrics, name: 'dc2', date: Date.yesterday)
          create(:collection_metric, display_collection: 'dc1', date: Date.yesterday)
          create(:collection_metric, date: Date.yesterday)

          get :root, params: { version: 'v3', facets: 'dc1', start_date: Date.yesterday, end_date: Date.yesterday }
          json = JSON.parse(response.body)

          expect(json.first['record'].count).to eq(1)
          expect(json.first['view'].count).to eq(1)
        end
      end

      context "failure requests" do
        it 'responds with a 400 status if the facets parameter is missing' do
          get :root, params: { version: 'v3' }

          expect(response.status).to eq(400)
        end

        it 'responds with a 400 status if the number of facets requested is greater than 10' do
          get :root, params: { version: 'v3', facets: '1,2,3,4,5,6,7,8,9,10,11' }

          expect(response.status).to eq(400)
        end
      end
    end

    describe 'GET facets' do
      before do
        allow(SupplejackApi::FacetsHelper).to receive(:get_list_of_facet_values).with(any_args).and_return([
          '1', '2', '3', '4', '5'
        ])
      end

      after do
        expect(response.body).to match_response_schema('metrics/facets_response')
      end

      it 'responds with a list of all facets' do
        5.times{create(:faceted_metrics)}

        get :facets, params: { version: 'v3' }
        json = JSON.parse(response.body)

        expect(json.length).to eq(5)
      end
    end
  end
end
