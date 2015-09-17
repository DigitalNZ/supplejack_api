require 'spec_helper'

module MetricsApi
  module V3
    module Endpoints
      describe Facets do
        let(:facet) {Facets.new(nil)}

        describe "#call" do
          it 'returns a list of all facets' do
            create(:daily_item_metric)

            expect(facet.call).to eq(['dc1', 'dc2'])
          end
        end
      end
    end
  end
end
