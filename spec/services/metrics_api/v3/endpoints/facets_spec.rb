require 'spec_helper'

module MetricsApi
  module V3
    module Endpoints
      describe Facets, search: true, slow: true do
        let(:facet) {Facets.new(nil)}

        before do
          Sunspot.session = Sunspot.session.original_session
        end

        describe "#call" do
          it 'returns a list of all facets' do
            create(:record_with_fragment, display_collection: 'dc1')
            create(:record_with_fragment, display_collection: 'dc2')
            Sunspot.commit

            expect(facet.call).to eq(['dc1', 'dc2'])
          end
        end
      end
    end
  end
end
