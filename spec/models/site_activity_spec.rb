

require 'spec_helper'

module SupplejackApi
  describe SiteActivity do

    let(:user) { create(:user) }

    context 'validations' do
      it 'should be invalid when there is a existing site_activity with the same date' do
        SupplejackApi::SiteActivity.create(date: Date.today)
        expect(SupplejackApi::SiteActivity.new(date: Date.today)).to_not be_valid
      end
    end

    describe '.generate_activity' do
      ['user_sets', 'search', 'records'].each do |field|
        it 'agregates #{field} totals across all users' do
          create(:user_activity, user_id: user.id, field.to_sym => {'total' => 10})
          create(:user_activity, user_id: user.id, field.to_sym => {'total' => 5})

          site_activity = SupplejackApi::SiteActivity.generate_activity
          expect(site_activity.send(field)).to eq 15
        end
      end

      it 'only agregates user activities from the last 12 hours' do
        create(:user_activity, user_id: user.id, :search => {'total' => 10}, created_at: Time.zone.now-14.hours)
        site_activity = SupplejackApi::SiteActivity.generate_activity
        expect(site_activity.search).to eq 0
      end

      it 'stores yesterday\'s date' do
        Timecop.freeze(Time.zone.now) do
          site_activity = SupplejackApi::SiteActivity.generate_activity
          expect(site_activity.date).to eq Time.zone.now.to_date
        end
      end

      it 'adds up a grand total' do
        create(:user_activity, user_id: user.id, :records => {'total' => 10})
        create(:user_activity, user_id: user.id, :user_sets => {'total' => 5})

        site_activity = SupplejackApi::SiteActivity.generate_activity
        expect(site_activity.total).to eq 15
      end

      context 'specify a date in the past' do
        before do
          create(:user_activity, user_id: user.id, :records => {'total' => 10}, created_at: Time.zone.now - 26.hours)
          create(:user_activity, user_id: user.id, :user_sets => {'total' => 5}, created_at: Time.zone.now - 28.hours)
        end

        it 'generates the site activity for a day in the past' do
          site_activity = SupplejackApi::SiteActivity.generate_activity(Time.zone.now-24.hours)
          expect(site_activity.total).to eq 15
        end

        it 'should add up user activity created after the date' do
          create(:user_activity, user_id: user.id, :records => {'total' => 2}, created_at: Time.zone.now)
          site_activity = SupplejackApi::SiteActivity.generate_activity(Time.zone.now-24.hours)
          expect(site_activity.total).to eq 15
        end

        it 'should add source_clicks from SourceActivity to total and reset SourceActivity' do
          allow(SourceActivity).to receive(:get_source_clicks) { 2 }
          expect(SupplejackApi::SourceActivity).to receive(:reset)
          site_activity = SupplejackApi::SiteActivity.generate_activity
          expect(site_activity.total).to eq 2
        end
      end
    end

    describe '#activities' do
      it 'should return only the custom fields' do
        expect(SupplejackApi::SiteActivity.activities).to_not include '_id'
      end

      it 'should include date' do
        expect(SupplejackApi::SiteActivity.activities).to include 'date'
      end
    end

    describe '#calculate_total' do
      let(:site_activity) { SupplejackApi::SiteActivity.new }

      it 'adds up the totals from every activity' do
        site_activity.search = 1
        site_activity.records = 2
        site_activity.user_sets = 3
        site_activity.source_clicks = 3
        site_activity.calculate_total
        expect(site_activity.total).to eq 9
      end
    end
  end
end
