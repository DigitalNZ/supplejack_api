# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require "spec_helper"

module SupplejackApi
  describe DailyItemMetricsWorker do

    describe "#call" do
      def build_records(first_batch_date, second_batch_date)
        display_collection_one   = build(:record_fragment, display_collection: 'pc1', copyright: ['0'],      category: ['0'])
        display_collection_two   = build(:record_fragment, display_collection: 'pc2', copyright: ['1'],      category: ['1'])
        display_collection_three = build(:record_fragment, display_collection: 'pc1', copyright: ['0', '1'], category: ['0', '1'])

        10.times do
          rec1 = build(:record, created_at: first_batch_date.midday)
          rec2 = build(:record, created_at: first_batch_date.midday)

          rec1.fragments << display_collection_one
          rec2.fragments << display_collection_two
          rec1.save
          rec2.save
        end

        10.times do
          rec = build(:record, created_at: second_batch_date.midday)
          rec.fragments << display_collection_three
          rec.save
        end
      end

      def facet_metrics_query(result, expected_results, &accessor_block)
        result.each_with_index do |facet, index|
          expect(accessor_block.call(facet, index)).to eq(expected_results[index])
        end
      end

      it "handles records with missing categories/copyrights" do
        10.times do |n|
          c = n % 2 == 0 ? nil : ['0']
          f = build(:record_fragment, copyright: c)
          r = build(:record, created_at: Date.current.midday)
          r.fragments << f
          r.save
        end

        DailyItemMetricsWorker.new.call(Date.current)

        expect(DailyItemMetric.last.total_active_records).to eq(10)
      end

      it "handles copyrights with periods in the name" do
        frag = build(:record_fragment, copyright: ['1.0'], display_collection: 'test')
        record = build(:record, created_at: Date.current.midday)
        record.fragments << frag
        record.save!

        DailyItemMetricsWorker.new.call(Date.current)
        expect(FacetedMetrics.created_on(Date.current).first.copyright_counts.first.first).to eq("1.0")
      end

      context "full run" do
        before do
          create(:record_with_fragment, status: "deleted") # inactive, should never show in counts

          build_records(Date.current - 2.days, Date.current - 3.days) 
          DailyItemMetricsWorker.new.call(Date.current - 2.days)
        end
        let(:daily_item_metric){SupplejackApi::DailyItemMetric.last}
        let(:faceted_metrics)  {SupplejackApi::FacetedMetrics.all.to_a}

        it "counts the total number of active records" do
          expect(daily_item_metric.total_active_records).to eq(30)
        end

        it "counts the total number of new records" do
          expect(daily_item_metric.total_new_records).to eq(20)
        end

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

        it "does not include Records created after the supplied date in the count" do
          10.times do
            create(:record_with_fragment, created_at: Date.current + 2.days)
          end
          DailyItemMetricsWorker.new.call(Date.current)

          expect(DailyItemMetric.last.total_active_records).to eq(30)
        end
      end
    end
  end
end
