# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Records Endpoints', type: :request do
  let(:user)   { create(:user) }
  let(:record) { create(:record, name: Faker::Movie.title) }

  describe '#index' do
    before do
      allow_any_instance_of(SupplejackApi::RecordSearch)
        .to receive(:results).and_return([record])

      allow_any_instance_of(SupplejackApi::RecordSearch)
        .to receive(:total).and_return(1)

      get "/v3/records.json?api_key=#{user.authentication_token}"
    end

    it 'returns records' do
      response_attributes = JSON.parse(response.body)

      expect(response_attributes).to eq(
        {
          'search' => {
            'facets' => {},
            'page' => 1,
            'per_page' => 20,
            'request_url' => "http://www.example.com/v3/records.json?api_key=#{user.authentication_token}",
            'result_count' => 1,
            'results' => [
              { 'address' => record.address,
                'created_at' => record.created_at.strftime('%y/%d/%m'),
                'email' => [],
                'name' => record.name,
                'updated_at' => record.created_at.as_json }
            ]
          }
        }
      )
    end
  end

  describe '#show' do
    context 'when record id dosent exist' do
      let(:record_id) { Faker::Lorem.word }

      before { get "/v3/records/#{record_id}.json?api_key=#{user.authentication_token}" }

      it 'returns record not found error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq({ 'errors' => I18n.t('errors.record_not_found', id: record_id) })
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
    before do
      params = { record_ids: [record.record_id] }.to_query
      get "/v3/records/multiple.json?api_key=#{user.authentication_token}&#{params}"
    end

    it 'returns record' do
      response_attributes = JSON.parse(response.body)

      expect(response_attributes).to eq(
        'records' => [{ 'address' => record.address,
                        'age' => record.age,
                        'age_str' => record.age_str,
                        'birth_date' => record.birth_date,
                        'birth_date_str' => record.birth_date_str,
                        'block_example' => 'Value of the block',
                        'category' => record.category,
                        'children' => record.children,
                        'contact' => record.contact,
                        'content_partner' => record.content_partner,
                        'contributing_partner' => record.contributing_partner,
                        'copyright' => record.copyright,
                        'created_at' => record.created_at.strftime('%y/%d/%m'),
                        'created_at_str' => record.created_at_str,
                        'creator' => record.creator,
                        'default_example' => 'Default value',
                        'description' => record.description,
                        'display_collection' => record.display_collection,
                        'email' => record.email,
                        'fragments' => record.fragments,
                        'id' => record.id.to_s,
                        'internal_identifier' => record.internal_identifier,
                        'landing_url' => record.landing_url,
                        'large_thumbnail_url' => record.large_thumbnail_url,
                        'name' => record.name,
                        'nz_citizen' => record.nz_citizen,
                        'record_id' => record.record_id,
                        'record_type' => record.record_type,
                        'rights' => record.rights,
                        'status' => record.status,
                        'subject' => record.subject,
                        'tag' => record.tag,
                        'thumbnail_url' => record.thumbnail_url,
                        'title' => record.title,
                        'updated_at' => record.updated_at.as_json }]
      )
    end
  end

  describe '#more_like_this' do
    before do
      allow_any_instance_of(Sunspot::Rails::StubSessionProxy::Search)
        .to receive(:results).and_return([record])

      get "/v3/records/#{record.record_id}/more_like_this.json?api_key=#{user.authentication_token}"
    end

    it 'returns record' do
      response_attributes = JSON.parse(response.body)

      expect(response_attributes).to eq(
        'records' => [{ 'address' => record.address,
                        'created_at' => record.created_at.as_json,
                        'email' => record.email,
                        'name' => record.name,
                        'updated_at' => record.updated_at.as_json }]
      )
    end
  end
end
