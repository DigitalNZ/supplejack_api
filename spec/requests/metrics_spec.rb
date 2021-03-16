require 'spec_helper'

RSpec.describe 'Metrics', type: :request do
  let(:admin) { create(:admin_user) }

  describe '#root' do
    context 'no facets provided' do
      before { get '/v3/metrics' }

      it 'returns user info' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq ({ 'errors' => 'facets parameter is required' })
      end
    end
  end

  describe '#facets' do
    it 'returns facets'
  end

  describe '#global' do
    it 'returns glbal values'
  end
end
