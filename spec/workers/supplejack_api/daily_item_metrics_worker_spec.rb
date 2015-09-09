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

      def display_collection_query(result, expected_results, &accessor_block)
        result.display_collection_metrics.each_with_index do |pcm, index|
          expect(accessor_block.call(pcm, index)).to eq(expected_results[index])
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

        expect(DailyItemMetricsWorker.new.call(Date.current).total_active_records).to eq(10)
      end

      it "handles copyrights with periods in the name" do
        frag = build(:record_fragment, copyright: ['1.0'], display_collection: 'test')
        record = build(:record, created_at: Date.current.midday)
        record.fragments << frag
        record.save!

        result = DailyItemMetricsWorker.new.call(Date.current)
        expect(result.display_collection_metrics.first.copyright_counts.first.first).to eq("1.0")
      end

      context "full run" do

        before do
          create(:record_with_fragment, status: "deleted") # inactive, should never show in counts

          build_records(Date.current - 2.days, Date.current - 3.days) 
        end
        let(:full_run_result){DailyItemMetricsWorker.new.call(Date.current - 2.days)}

        it "counts the total number of active records" do
          expect(full_run_result.total_active_records).to eq(30)
        end

        it "has metrics for each display_collection" do
          expect(full_run_result.display_collection_metrics.length).to eq(2)
        end

        it "has active record counts for each display_collection" do
          display_collection_query(full_run_result, [20, 10]) {|pcm| pcm.total_active_records}
        end

        it "has new record counts for each display_collection" do
          display_collection_query(full_run_result, [10, 10]) {|pcm| pcm.total_new_records}
        end

        it "has a count of records per category in each display_collection" do
          display_collection_query(full_run_result, [20, 10]) {|pcm, index| pcm.category_counts[index.to_s]}
        end

        it "has a count of records per usage type in each display_collection" do
          display_collection_query(full_run_result, [20, 10]) {|pcm, index| pcm.copyright_counts[index.to_s]}
        end

        it "does not include Records created after the supplied date in the count" do
          10.times do
            create(:record_with_fragment, created_at: Date.current + 2.days)
          end

          expect(DailyItemMetricsWorker.new.call(Date.current).total_active_records).to eq(30)
        end
      end

      context "partial run" do
        before do
          build_records(Date.current, Date.current - 10.days) 
          @previous_metrics = DailyItemMetric.create(
            day: Date.current,
            total_active_records: 30,
            display_collection_metrics_attributes: [
              {
                name: "pc1", 
                total_active_records: 20, 
                total_new_records: 20,
                category_counts: {
                  "0" => 20,
                  "1" => 20
                },
                copyright_counts: {
                  "0" => 20,
                  "1" => 20
                }
              },
              {
                name: "pc2", 
                total_active_records: 20, 
                total_new_records: 20,
                category_counts: {
                  "0" => 20,
                  "1" => 20
                },
                copyright_counts: {
                  "0" => 20,
                  "1" => 20
                }
              },
              {
                name: "pc3",
                total_active_records: 0,
                total_new_records: 0,
                category_counts: {},
                copyright_counts: {}
              }
            ]
          )
        end
        let!(:partial_run_result){SupplejackApi::DailyItemMetricsWorker.new.call(Date.current - 1.day, @previous_metrics)}

        it "counts the total number of records" do
          expect(partial_run_result.total_active_records).to eq(50)
        end

        it "has active record counts for each display_collection" do
          display_collection_query(partial_run_result, [30, 30, 0]) {|pcm| pcm.total_active_records}
        end

        it "has new record counts for each display_collection" do
          display_collection_query(partial_run_result, [10, 10, 0]) {|pcm| pcm.total_new_records}
        end

        it "has a count of records per category in each display_collection" do
          display_collection_query(partial_run_result, [30, 30, nil]) {|pcm, index| pcm.category_counts[index.to_s]}
        end

        it "has a count of records per usage type in each display_collection" do
          display_collection_query(partial_run_result, [30, 30, nil]) {|pcm, index| pcm.copyright_counts[index.to_s]}
        end

        it "includes all display collection metrics from the previous run" do
          expect(partial_run_result.display_collection_metrics.last.name).to eq("pc3")
        end
      end
    end

    describe "#perform" do
      context "gap since previous full run" do
        before do
          DailyItemMetric.create(
            day: Date.current - 5.days,
            total_active_records: 30,
            display_collection_metrics_attributes: [
              {
                name: "pc1", 
                total_active_records: 20, 
                total_new_records: 20,
                category_counts: {
                  "0" => 20,
                },
                copyright_counts: {
                  "0" => 20,
                }
              }
            ]
          )

          display_collection = build(:record_fragment, display_collection: "pc1", category: ["0"], copyright: ["0"])
          [0, 1, 2, 3].each do |n|
            record = build(:record, created_at: Date.current - n.days)
            record.fragments << display_collection
            record.save
          end
        end

        it "performs incremental runs for each day in the gap" do
          DailyItemMetricsWorker.perform
          metric = DailyItemMetric.last

          expect(metric.total_active_records).to eq(34)
          expect(metric.display_collection_metrics.first.total_active_records).to eq(24)
        end
      end
    end
  end
end
