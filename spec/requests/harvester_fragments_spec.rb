# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Harvester fragments', type: :request do
  let(:record) { create(:record_with_fragment) }
  let(:harvester) { create(:harvest_user) }
  let(:fragment_payload) do
    {
      fragment: {
        priority: 1,
        source_id: 'enrichment_source',
        job_id: '5c7efbecf1676244abdca448',
        subject: ['Enriched subject']
      }
    }
  end

  def post_fragment(token)
    post "/harvester/records/#{record.id}/fragments",
         params: fragment_payload.to_json,
         headers: { 'Authentication-Token' => token, 'Content-Type' => 'application/json' }
  end

  context 'with a harvester key' do
    before { post_fragment(harvester.authentication_token) }

    it 'reports success in the body' do
      # create renders 200 even when processing fails, so the body is the real signal
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq('status' => 'success', 'record_id' => record.record_id)
    end

    it 'persists the fragment on the record' do
      fragment = record.reload.find_fragment('enrichment_source')

      expect(fragment).to be_present
      expect(fragment.priority).to eq 1
      expect(fragment.job_id).to eq '5c7efbecf1676244abdca448'
      expect(fragment.subject).to eq ['Enriched subject']
      expect(record.fragments.size).to eq 2
    end
  end

  context 'with a non harvester key' do
    before { post_fragment(create(:user, role: 'developer').authentication_token) }

    it 'rejects the request' do
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['errors']).to eq I18n.t('errors.requires_harvest_privileges')
    end

    it 'does not write the fragment' do
      expect(record.reload.find_fragment('enrichment_source')).to be_nil
    end
  end

  context 'with an unknown key' do
    before { post_fragment('notARealKey') }

    it 'rejects the request' do
      expect(response).to have_http_status(:forbidden)
      expect(record.reload.find_fragment('enrichment_source')).to be_nil
    end
  end
end
