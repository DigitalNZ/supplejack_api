# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Meta field test', type: :request do
  let(:user)   { create(:user) }
  let(:record) { create(:record) }

  describe '#show' do
    context 'when global_response_field is not configured' do
      context 'when format is xml' do
        before { get "/v3/records/#{record.record_id}.xml?api_key=#{user.authentication_token}" }

        it 'returns record without meta' do
          expect(response.body).not_to include('<terms-of-use>terms_of_use</terms-of-use>')
        end
      end

      context 'when format is json' do
        before { get "/v3/records/#{record.record_id}.json?api_key=#{user.authentication_token}" }

        it 'returns record without meta' do
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
    end

    context 'when global_response_field is configured' do
      before { SupplejackApi.config.global_response_field = { key_name: 'terms_of_use', value: 'terms of use' } }
      after  { SupplejackApi.config.global_response_field = nil }

      context 'when format is xml' do
        before { get "/v3/records/#{record.record_id}.xml?api_key=#{user.authentication_token}" }

        it 'returns record with meta' do
          expect(response.body).to include('<terms-of-use>terms of use</terms-of-use>')
        end
      end

      context 'when format is json' do
        before { get "/v3/records/#{record.record_id}.json?api_key=#{user.authentication_token}" }

        it 'returns record with meta' do
          response_attributes = JSON.parse(response.body)

          expect(response_attributes).to eq(
            {
              'terms_of_use' => 'terms of use',
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
end
