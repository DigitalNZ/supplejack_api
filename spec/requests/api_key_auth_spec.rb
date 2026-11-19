# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'API key authentication', type: :request do
  let(:legacy_token) { 'legacyTokenAbc123xyz' }
  let(:record) { create(:record, name: 'Keyed record') }

  before do
    create(:user, authentication_token: legacy_token, role: 'developer')

    allow_any_instance_of(SupplejackApi::RecordSearch).to receive(:results).and_return([record])
    allow_any_instance_of(SupplejackApi::RecordSearch).to receive(:total).and_return(1)
  end

  it 'accepts a stored token in the Authentication-Token header' do
    get '/v3/records.json', headers: { 'Authentication-Token' => legacy_token }

    expect(response).to have_http_status(:ok)
  end

  it 'accepts a stored token in the api_key param' do
    get "/v3/records.json?api_key=#{legacy_token}"

    expect(response).to have_http_status(:ok)
  end

  it 'rejects an unknown api_key' do
    get '/v3/records.json?api_key=wrong'

    expect(response).to have_http_status(:forbidden)
  end
end
