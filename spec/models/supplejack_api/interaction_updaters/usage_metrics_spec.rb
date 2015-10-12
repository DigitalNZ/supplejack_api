require 'spec_helper'

module SupplejackApi
  module InteractionUpdaters
    describe UsageMetrics do
      let(:updater) {InteractionUpdaters::UsageMetrics.new}

      before do
        @request_logs = ['search', 'get', 'user_set'].map do |request_type|
          create(:record_interaction, request_type: request_type, log_values: ['test'])
        end
      end

      it 'takes an array of Record interactions and creates a UsageMetrics model' do
        updater.process(@request_logs)
        metric = SupplejackApi::UsageMetrics.first 

        expect(metric).to be_present
        expect(metric.record_field_value).to eq('test')
        expect(metric.searches      ).to eq(1)
        expect(metric.gets          ).to eq(1)
        expect(metric.user_set_views).to eq(1)
      end

      it 'updates an existing UsageMetrics model if one exists' do
        create(:usage_metrics, record_field_value: 'test', searches: 1, gets: 1, user_set_views: 1, total: 3, day: Date.current)
        updater.process(@request_logs)
        metric = SupplejackApi::UsageMetrics.first

        expect(metric.searches      ).to eq(2)
        expect(metric.gets          ).to eq(2)
        expect(metric.user_set_views).to eq(2)
        expect(metric.total         ).to eq(6)
      end
    end
  end
end
