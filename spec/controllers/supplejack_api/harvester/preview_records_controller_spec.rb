# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe Harvester::PreviewRecordsController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    let(:record) { FactoryBot.build(:record) }

    context 'with a api_key with harvester role' do
      let(:api_key) { create(:user, role: 'harvester').api_key }

      describe 'GET index' do
        let(:fragment) { FactoryBot.build(:record_fragment, job_id: 54) }
        let!(:preview_record) { FactoryBot.create(:preview_record, fragments: [fragment]) }

        it 'returns array of records based on search params' do
          expect(SupplejackApi::PreviewRecord).to receive(:where).with({ 'fragments.job_id': '54' })

          get :index, params: { search:  { 'fragments.job_id': '54' }, api_key: api_key }
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

      it 'responds with 401 and no content' do
        get :index, params: { search:  { 'fragments.job_id': '54' }, api_key: admin_key }

        expect(response.status).to eq 401
        expect(response.body).to include 'You need Harvester privileges to perform this request.'
      end
    end
  end
end
