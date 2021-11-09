# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe Harvester::PreviewRecordsController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    let(:record) { build(:record) }

    context 'with a api_key with harvester role' do
      let(:harvester) { create(:user, role: 'harvester') }

      describe 'GET index' do
        let(:fragment) { build(:record_fragment, job_id: 54) }
        let!(:preview_record) { create(:preview_record, fragments: [fragment]) }

        it 'returns array of records based on search params' do
          expect(SupplejackApi::PreviewRecord).to receive(:where).with({ 'fragments.job_id': '54' })

          get :index, params: { search:  { 'fragments.job_id': '54' }, api_key: harvester.api_key }
        end

        it 'responds with a json object of record ids and the fragments fragments' do
          get :index, params: { search:  { 'fragments.job_id': '54' }, api_key: harvester.api_key }

          records = JSON.parse(response.body)
          records.each do |rec|
            expect(rec).to have_key 'id'
            expect(rec).to have_key 'fragments'
          end
        end
      end
    end

    context 'with api_key without harvester role' do
      let(:admin) { create(:admin_user) }

      it 'responds with 401 and no content' do
        get :index, params: { search:  { 'fragments.job_id': '54' }, api_key: admin.api_key }

        expect(response).to be_unauthorized
        expect(response.body).to include 'You need Harvester privileges to perform this request.'
      end
    end
  end
end
