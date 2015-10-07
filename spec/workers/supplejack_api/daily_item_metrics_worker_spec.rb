# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require "spec_helper"

module SupplejackApi
  describe DailyItemMetricsWorker, search: true, slow: true do

    after :each do
      Sunspot.remove_all
    end

    describe "#call" do
      def build_records
        10.times do
          create(:record_with_fragment, display_collection: 'pc1', copyright: ['0'],      category: ['0'], created_at: Date.current.midday)
          create(:record_with_fragment, display_collection: 'pc2', copyright: ['1'],      category: ['1'], created_at: Date.current.midday)
          create(:record_with_fragment, display_collection: 'pc1', copyright: ['0', '1'], category: ['0', '1'], created_at: Date.yesterday.midday)
        end

        Sunspot.commit
      end

      def facet_metrics_query(result, expected_results, &accessor_block)
        result.each_with_index do |facet, index|
          expect(accessor_block.call(facet, index)).to eq(expected_results[index])
        end
      end

      it "handles records with missing categories/copyrights" do
        10.times do |n|
          c = n % 2 == 0 ? nil : ['0']
          create(:record_with_fragment, created_at: Date.current.midday, copyright: c)
        end
        Sunspot.commit

        DailyItemMetricsWorker.new.call
        facet = SupplejackApi::FacetedMetrics.where(name: 'all').first

        expect(facet.total_active_records).to eq(10)
      end

      it "handles copyrights with periods in the name" do
        create(:record_with_fragment, copyright: ['1.0'], display_collection: 'test')
        Sunspot.commit

        DailyItemMetricsWorker.new.call
        expect(FacetedMetrics.created_on(Date.current).first.copyright_counts.first.first).to eq("1.0")
      end

      it "correctly paginates the facet list when there are more than 150 facets" do
        200.times do |n|
          create(:record_with_fragment, display_collection: n.to_s)
        end
        Sunspot.commit

        DailyItemMetricsWorker.new.call

        expect(FacetedMetrics.count).to eq(201)
      end

      context "metrics results" do
        before do
          create(:record_with_fragment, status: "deleted") # inactive, should never show in counts
          build_records

          DailyItemMetricsWorker.new.call
        end
        let(:faceted_metrics)  {SupplejackApi::FacetedMetrics.all.where(:name.ne => 'all').to_a}

        it "has metrics for each facet" do
          expect(faceted_metrics.length).to eq(2)
        end

        it "has active record counts for each facet" do
          facet_metrics_query(faceted_metrics, [20, 10]) {|facet| facet.total_active_records}
        end

        it "has new record counts for each display_collection" do
          facet_metrics_query(faceted_metrics, [10, 10]) {|facet| facet.total_new_records}
        end

        it "has a count of records per category in each display_collection" do
          facet_metrics_query(faceted_metrics, [20, 10]) {|facet, index| facet.category_counts[index.to_s]}
        end

        it "has a count of records per usage type in each display_collection" do
          facet_metrics_query(faceted_metrics, [20, 10]) {|facet, index| facet.copyright_counts[index.to_s]}
        end

        it "creates an All facet that contains the summed metrics of for all the individual facets" do
          all_metric = SupplejackApi::FacetedMetrics.where(name: 'all').first
          
          expect(all_metric.total_active_records).to eq(30)
          expect(all_metric.total_new_records).to eq(20)
          expect(all_metric.copyright_counts['0']).to eq(20)
        end
      end
    end
  end
end
