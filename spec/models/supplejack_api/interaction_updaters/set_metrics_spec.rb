require 'spec_helper'

module SupplejackApi
  module InteractionUpdaters
    describe SetMetrics do
      let(:updater){InteractionUpdaters::SetMetrics.new}

      before do
        @set_interactions = ['test1', 'test2', 'test1'].map do |collection|
          create(:set_interaction, facet: collection)
        end
      end

      it 'takes an array of Set interactions and creates a UsageMetrics model' do
        updater.process(@set_interactions)
        metric = SupplejackApi::UsageMetrics.first

        expect(metric).to be_present
        expect(metric.record_field_value).to eq('test1')
        expect(metric.records_added_to_user_sets).to eq(2)
      end

      it 'updates an existing UsageMetrics model if one exists' do
        create(:usage_metrics, record_field_value: 'test1', records_added_to_user_sets: 2, date: Time.now.utc.to_date)
        updater.process(@set_interactions)
        metric = SupplejackApi::UsageMetrics.first

        expect(metric.records_added_to_user_sets).to eq(4)
      end
    end
  end
end
