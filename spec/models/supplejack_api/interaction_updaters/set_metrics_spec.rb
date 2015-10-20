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

      it 'takes an array of Set interactions and creates a SetMetrics model' do
        updater.process(@set_interactions)
        metric = SupplejackApi::SetMetrics.first 

        expect(metric).to be_present
        expect(metric.facet).to eq('test1')
        expect(metric.total_records_added).to eq(2)
      end

      it 'creates a SetMetrics model for all unique facets' do
        updater.process(@set_interactions)

        expect(SupplejackApi::SetMetrics.count).to eq(2)
      end

      it 'updates an existing SetMetrics model if one exists' do
        create(:set_metrics, facet: 'test1', total_records_added: 2, day: Date.current)
        updater.process(@set_interactions)
        metric = SupplejackApi::SetMetrics.first

        expect(metric.total_records_added).to eq(4)
      end
    end
  end
end
