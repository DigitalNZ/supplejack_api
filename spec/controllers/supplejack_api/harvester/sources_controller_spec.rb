# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe Harvester::SourcesController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    let(:partner) { FactoryBot.create(:partner) }

    context 'with a api_key with harvester role' do
      let(:api_key) { create(:user, role: 'harvester').api_key }

      before do
        allow(RecordSchema).to receive(:roles) { { harvester: double(:harvester, harvester: true) } }
      end

      describe 'POST create' do
        it 'creates a new source' do
          expect do
            post :create, params: { partner_id: partner, source: FactoryBot.attributes_for(:source), api_key: api_key }
          end.to change { Source.count }.by 1

          expect(response).to be_successful
        end

        it 'returns the source' do
          post :create, params: { partner_id: partner, source: FactoryBot.attributes_for(:source), api_key: api_key }
          partner.reload
          expect(response.body).to include Source.last.to_json
        end

        context 'source already exists' do
          it 'updates the source' do
            source = partner.sources.create(FactoryBot.attributes_for(:source, source_id: 'source_1'))

            post :create, params: {
              partner_id: partner,
              source: { _id: source.id, source_id: 'source2' },
              api_key: api_key
            }

            source.reload
            expect(source.source_id).to eq 'source2'
          end
        end
      end

      describe 'GET "show"' do
        let(:source) { create(:source) }

        it 'assigns the source' do
          get :show, params: { id: source.id, api_key: api_key }

          expect(assigns(:source)).to eq source
        end

        it 'returns the source' do
          get :show, params: { id: source.id, api_key: api_key }

          expect(response.body).to eq source.to_json
        end
      end

      describe 'GET index' do
        let(:sources) { [FactoryBot.build(:source)] }

        it 'assigns all sources' do
          get :index, params: { api_key: api_key }

          expect(assigns(:sources)).to eq Source.all
        end

        it 'returns all sources' do
          get :index, params: { api_key: api_key }

          expect(response.body).to include Source.all.to_json
        end

        context 'limit and order sources' do
          before do
            status_updated_at = Faker::Date.between(from: 2.days.ago.utc.to_date, to: Time.now.utc.to_date)
            FactoryBot.create_list(:source, 11,
                                   status: 'active',
                                   status_updated_at: status_updated_at)
            FactoryBot.create_list(:source, 5, status: 'suppressed')
          end

          it 'returns sources ordered and limitted by limit:' do
            get :index, params: {
              source: { status: 'active' },
              limit: 10,
              order_by: 'status_updated_at',
              api_key: api_key
            }

            expect(JSON.parse(response.body).count).to be 10
          end

          it 'returns ordered sources' do
            get :index, params: {
              source: { status: 'active' },
              limit: 10,
              order_by: 'status_updated_at',
              api_key: api_key
            }

            expect(response.body).to eq Source.where(status: 'active')
                                              .order_by(status_updated_at: 'desc')
                                              .limit(10).to_json
          end
        end

        context 'search' do
          let(:suppressed_source) { FactoryBot.build(:source)  }

          it 'searches the sources if params source is defined' do
            expect(Source).to receive(:where).with('status' => 'suppressed')
            get :index, params: { source: { status: 'suppressed' }, api_key: api_key }
          end
        end
      end

      describe 'PUT update' do
        let(:source) { FactoryBot.create(:source) }

        it 'finds and update source with status, status_updated_at and status_updated_by' do
          Timecop.freeze # check if Time.now.utc was assigned to status_updated_at
          put :update, params: {
            id: source.id,
            source: { status: 'suppressed', status_updated_by: 'A user name' },
            api_key: api_key
          }

          expect(assigns(:source).status).to eq 'suppressed'
          expect(assigns(:source).status_updated_by).to eq 'A user name'
          expect(assigns(:source).status_updated_at).to eq Time.now.utc
        end

        it 'returns the source' do
          put :update, params: {
            id: source.id,
            source: { status: 'suppressed', status_updated_by: 'A user name' },
            api_key: api_key
          }

          expect(response.body).to include 'status'
          expect(response.body).to include 'status_updated_at'
          expect(response.body).to include 'status_updated_by'
        end
      end

      describe 'GET reindex' do
        let(:source) { create(:source) }

        it 'enqueues the job with the source_id and date if given' do
          date = Time.now.utc
          expect(IndexSourceWorker).to receive(:perform_async).with(source.source_id, date.to_s)
          get :reindex, params: { id: source.id, date: date, api_key: api_key }
        end
      end

      describe 'GET "link_check_records"' do
        let(:records) do
          [double(:record, landing_url: 'http://1'),
           double(:record, landing_url: 'http://2'),
           double(:record, landing_url: 'http://3'),
           double(:record, landing_url: 'http://4')]
        end

        let(:source) { FactoryBot.build(:source, source_id: 'source_name') }

        before do
          allow(Source).to receive(:find) { source }
          allow(source).to receive(:random_records) { records }
        end

        it 'should call the random records methid for source with 4' do
          expect(source).to receive(:random_records).with(4)

          get :link_check_records, params: { id: source.id, api_key: api_key }
        end

        it 'should asign the oldest two records by syndication_date' do
          get :link_check_records, params: { id: source.id, api_key: api_key }

          # rubocop:disable Style/StringLiterals
          expect(response.body).to eq "[\"http://1\",\"http://2\",\"http://3\",\"http://4\"]"
          # rubocop:enable Style/StringLiterals
        end
      end
    end

    context 'with api_key without harvester role' do
      let(:api_key) { create(:user, role: 'admin').api_key }

      before do
        allow(RecordSchema).to receive(:roles) { { harvester: double(:harvester, harvester: nil) } }
      end

      describe 'GET link_check_records' do
        it 'returns forbidden' do
          get :link_check_records, params: { id: 1, api_key: api_key }

          expect(response).to be_forbidden
        end
      end

      describe 'GET reindex' do
        it 'returns forbidden' do
          get :reindex, params: { id: 1, date: Time.now.utc, api_key: api_key }

          expect(response).to be_forbidden
        end
      end

      describe 'PUT update' do
        it 'returns forbidden' do
          put :update, params: { id: 1, source: { status: 'suppressed' }, api_key: api_key }

          expect(response).to be_forbidden
        end
      end

      describe 'GET index' do
        it 'returns forbidden' do
          get :index, params: { api_key: api_key }

          expect(response).to be_forbidden
        end
      end

      describe 'GET "show"' do
        it 'returns forbidden' do
          get :show, params: { id: 1, api_key: api_key }

          expect(response).to be_forbidden
        end
      end

      describe 'POST "create"' do
        it 'returns forbidden' do
          post :create, params: { partner_id: 1, source: FactoryBot.attributes_for(:source), api_key: api_key }

          expect(response).to be_forbidden
        end
      end
    end
  end
end
