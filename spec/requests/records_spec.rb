require 'spec_helper'

RSpec.describe 'Records Endpoints', type: :request do
  let(:user)   { create(:user) }
  let(:record) { create(:record) }

  describe '#index' do
    context 'whithout any search params' do
    end

    context 'with search params' do
    end
  end

  describe '#show' do
    context 'when record id dosent exist' do
      let(:record_id) { Faker::Lorem.word }

      before { get "/v3/records/#{record_id}.json?api_key=#{user.authentication_token}" }

      it 'returns record not found error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => I18n.t('errors.record_not_found', id: record_id) })
      end
    end

    context 'when record id exists' do
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
  end

  describe '#multiple' do
  end

  describe '#more_like_this' do
  end
end