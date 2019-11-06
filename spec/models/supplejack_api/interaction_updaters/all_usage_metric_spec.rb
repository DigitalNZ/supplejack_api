require 'spec_helper'

module SupplejackApi
  module InteractionUpdaters
    describe AllUsageMetric do
      let(:updater){InteractionUpdaters::AllUsageMetric.new}
      let!(:usage_metrics) {[create(:usage_metrics, record_field_value: '1'), create(:usage_metrics, record_field_value: '2')]}
      let(:all_usage_metric) {SupplejackApi::UsageMetrics.where(record_field_value: 'all').last}

      it 'creates a new "all" usage metric with the summed values of the other usage metrics if one does not exist' do
        updater.process

        expect(all_usage_metric.searches).to eq(2)
        expect(all_usage_metric.gets).to eq(2)
        expect(all_usage_metric.user_set_views).to eq(2)
        expect(all_usage_metric.total_views).to eq(2)
        expect(all_usage_metric.records_added_to_user_sets).to eq(2)
      end

      it 'updates the "all" usage metric with the summed values of the other usage metrics if one does exist' do
        create(:usage_metrics, record_field_value: 'all')

        updater.process

        expect(all_usage_metric.searches).to eq(2)
        expect(all_usage_metric.gets).to eq(2)
        expect(all_usage_metric.user_set_views).to eq(2)
        expect(all_usage_metric.total_views).to eq(2)
        expect(all_usage_metric.records_added_to_user_sets).to eq(2)
      end

      it 'does not process UsageMetrics created in the past' do
        create(:usage_metrics, date: Time.now.utc.yesterday.to_date)

        updater.process

        expect(all_usage_metric.searches).to eq(2)
      end
    end
  end
end
