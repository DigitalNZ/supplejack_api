# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Meta field test', type: :request do
  let(:user)   { create(:user) }
  let(:record) { create(:record, name: Faker::Movie.title) }

  describe '#show' do
    context 'when meta_response_field is not configured' do
      before { get "/v3/records/#{record.record_id}.json?api_key=#{user.authentication_token}" }

      it 'returns record' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq(
          {
            'record' => {
              'address' => record.address,
              'created_at' => record.created_at.strftime('%y/%d/%m'),
              'email' => record.email,
              'name' => record.name,
              'updated_at' => record.created_at.as_json
            }
          }
        )
      end
    end

    context 'when meta_response_field is configured' do
      before do
        SupplejackApi.config.meta_response_field = { terms_of_use: 'terms_of_use' }

        get "/v3/records/#{record.record_id}.json?api_key=#{user.authentication_token}"
      end

      after { SupplejackApi.config.meta_response_field = nil }

      it 'returns record with meta' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq(
          {
            'meta' => { 'terms_of_use' => 'terms_of_use' },
            'record' => {
              'address' => record.address,
              'created_at' => record.created_at.strftime('%y/%d/%m'),
              'email' => record.email,
              'name' => record.name,
              'updated_at' => record.created_at.as_json
            }
          }
        )
      end
    end
  end
end
