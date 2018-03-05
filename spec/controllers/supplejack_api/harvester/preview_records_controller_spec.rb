require "spec_helper"

module SupplejackApi
  describe Harvester::RecordsController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    let(:record) { FactoryBot.build(:record) }

    context 'with a api_key with harvester role' do
      let(:api_key) { create(:user, role: 'harvester').api_key }

      before do
        allow(RecordSchema).to receive(:roles) { { harvester: double(:harvester, harvester: true) } }
      end

      describe 'GET index' do
        let!(:record) { FactoryBot.create_list(:record_with_fragment, 101) }

        it 'returns array of records based on search params' do
          expect(Record).to receive(:where).with({'fragments.job_id': '54'})
          get :index, params: { search:  { 'fragments.job_id': '54' }, api_key: api_key }
        end

        it 'only returns 100 results' do
          get :index, params: { search:  { 'fragments.job_id': '54' }, api_key: api_key }
          expect(assigns(:records).count).to eq 100
        end

        it 'responds with a json object of record ids and the fragments fragments' do
          get :index, params: { search:  { 'fragments.job_id': '54' }, api_key: api_key }
          records = JSON.parse(response.body)

          records.each do |rec|
            expect(rec).to have_key 'id'
            expect(rec).to have_key 'fragments'
          end
        end
      end
    end

    context 'with api_key without harvester role' do
      let(:admin_key) { create(:user, role: 'admin').api_key }

      before do
        allow(RecordSchema).to receive(:roles) { { harvester: double(:harvester, harvester: nil) } }
      end

      it 'responds with 403 and no content' do
        get :index, params: { search:  { 'fragments.job_id': '54' }, api_key: admin_key }

        expect(response.status).to eq 403
        expect(response.body).to include 'You need Harvester privileges to perform this request.'
      end
    end
  end
end
