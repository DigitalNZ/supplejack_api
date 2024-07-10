# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Metrics Endpoints', type: :request do
  describe '#root' do
    context 'when no facets provided' do
      before { get '/v3/metrics.json?' }

      it 'returns error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq({ 'errors' => 'facets parameter is required' })
      end
    end

    context 'when facets length is more than MAX_FACETS' do
      before do
        params = { facets: (1..11).to_a.join(',') }.to_query
        get "/v3/metrics.json?#{params}"
      end

      it 'returns error' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq({ 'errors' => 'Only up to 10 may be requested at once' })
      end
    end

    xcontext 'when default metrics data for all facets is requested' do
      let(:all) do
        create(:collection_metric,
               display_collection: 'all',
               created_at: Time.zone.yesterday.to_date.midday,
               date: Time.zone.yesterday.to_date,
               searches: Faker::Number.number(digits: 10),
               record_page_views: Faker::Number.number(digits: 10),
               user_set_views: Faker::Number.number(digits: 10),
               total_views: Faker::Number.number(digits: 10),
               records_added_to_user_sets: Faker::Number.number(digits: 10),
               total_source_clickthroughs: Faker::Number.number(digits: 10),
               user_story_views: Faker::Number.number(digits: 10),
               records_added_to_user_stories: Faker::Number.number(digits: 10))
      end

      before do
        params = { facets: all.display_collection }.to_query

        get "/v3/metrics.json?&#{params}"
      end

      it 'returns view & record metrics for all collections' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq(
          [
            {
              'date' => Time.zone.now.yesterday.to_date.to_s,
              'record' => [],
              'view' => [
                {
                  'id' => 'all',
                  'record_page_views' => all.record_page_views,
                  'records_added_to_user_sets' => all.records_added_to_user_sets,
                  'records_added_to_user_stories' => all.records_added_to_user_stories,
                  'searches' => all.searches,
                  'total_source_clickthroughs' => all.total_source_clickthroughs,
                  'total_views' => all.total_views,
                  'user_set_views' => all.user_set_views,
                  'user_story_views' => all.user_story_views
                }
              ]
            }
          ]
        )
      end
    end

    xcontext 'when default metrics data for flikr facet is requested' do
      let(:flikr) do
        create(:collection_metric,
               display_collection: 'flikr',
               created_at: Time.zone.yesterday.to_date.midday,
               date: Time.zone.yesterday.to_date)
      end

      before do
        params = { facets: flikr.display_collection }.to_query

        get "/v3/metrics.json?&#{params}"
      end

      it 'returns view & record metrics for collection flikr' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq(
          [
            {
              'date' => Time.zone.now.yesterday.to_date.to_s,
              'record' => [],
              'view' => [
                {
                  'id' => 'flikr',
                  'record_page_views' => flikr.record_page_views,
                  'records_added_to_user_sets' => flikr.records_added_to_user_sets,
                  'records_added_to_user_stories' => flikr.records_added_to_user_stories,
                  'searches' => flikr.searches,
                  'total_source_clickthroughs' => flikr.total_source_clickthroughs,
                  'total_views' => flikr.total_views,
                  'user_set_views' => flikr.user_set_views,
                  'user_story_views' => flikr.user_story_views
                }
              ]
            }
          ]
        )
      end
    end

    xcontext 'when view metrics data for all facets is requested' do
      let(:all) do
        create(:collection_metric,
               display_collection: 'all',
               created_at: Time.zone.yesterday.to_date.midday,
               date: Time.zone.yesterday.to_date,
               searches: Faker::Number.number(digits: 10),
               record_page_views: Faker::Number.number(digits: 10),
               user_set_views: Faker::Number.number(digits: 10),
               total_views: Faker::Number.number(digits: 10),
               records_added_to_user_sets: Faker::Number.number(digits: 10),
               total_source_clickthroughs: Faker::Number.number(digits: 10),
               user_story_views: Faker::Number.number(digits: 10),
               records_added_to_user_stories: Faker::Number.number(digits: 10))
      end

      before do
        params = { facets: all.display_collection, metrics: 'view' }.to_query

        get "/v3/metrics.json?&#{params}"
      end

      it 'returns view metrics for all collections' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq(
          [
            {
              'date' => Time.zone.now.yesterday.to_date.to_s,
              'view' => [
                {
                  'id' => 'all',
                  'record_page_views' => all.record_page_views,
                  'records_added_to_user_sets' => all.records_added_to_user_sets,
                  'records_added_to_user_stories' => all.records_added_to_user_stories,
                  'searches' => all.searches,
                  'total_source_clickthroughs' => all.total_source_clickthroughs,
                  'total_views' => all.total_views,
                  'user_set_views' => all.user_set_views,
                  'user_story_views' => all.user_story_views
                }
              ]
            }
          ]
        )
      end
    end

    context 'when record metrics data for facets is requested' do
      let(:facet1) { create(:faceted_metrics, name: 'facet-1') }
      let(:facet2) { create(:faceted_metrics, name: 'facet-2') }

      before do
        params = { facets: "#{facet1.name},#{facet2.name}", metrics: 'record',
                   start_date: Time.now.utc.to_date.strftime,
                   end_date: Time.now.utc.to_date.strftime }.to_query

        get "/v3/metrics.json?&#{params}"
      end

      it 'returns view metrics for all collections' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq(
          [
            {
              'date' => Time.now.utc.to_date.strftime,
              'record' => [
                { 'category_counts' => facet1.category_counts,
                  'copyright_counts' => facet1.copyright_counts,
                  'id' => facet1.name,
                  'total_active_records' => facet1.total_active_records,
                  'total_new_records' => facet1.total_new_records },
                { 'category_counts' => facet2.category_counts,
                  'copyright_counts' => facet2.copyright_counts,
                  'id' => facet2.name,
                  'total_active_records' => facet2.total_active_records,
                  'total_new_records' => facet2.total_new_records }
              ]
            }
          ]
        )
      end
    end

    context 'when top_records metrics data for facets is requested' do
      let(:top_record) do
        create(:top_collection_metric,
               m: 'appeared_in_searches', r: { '44167341': 3 },
               c: 'flikr', d: Time.zone.yesterday.to_date,
               created_at: Time.now.utc.to_date.midday)
      end

      before do
        params = { facets: top_record.c, metrics: 'top_records',
                   start_date: Time.zone.yesterday.to_date.strftime,
                   end_date: Time.now.utc.to_date.strftime }.to_query

        get "/v3/metrics.json?&#{params}"
      end

      it 'returns metrics for top_records' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes.first).to eq(
          {
            'date' => Time.zone.yesterday.to_date.strftime,
            'top_records' => { top_record.m => top_record.r }
          }
        )
      end
    end
  end

  describe '#facets' do
    before do
      # This mocks the results for querying with page sequentially
      allow(SupplejackApi::RecordSearch)
        .to receive(:new)
        .with(facets: 'display_collection', facets_per_page: 150, facets_page: 1)
        .and_return(
          double('SupplejackApi::RecordSearch',
                 facets_hash: { primary_collection: { 'National Library of New Zealand' => 100, 'Radio New Zealand' => 200 } })
        )

      # We have to return an empty facets_hash as the helper runs an infinite loop till it encounters an empty facets_hash
      allow(SupplejackApi::RecordSearch)
        .to receive(:new)
        .with(facets: 'display_collection', facets_per_page: 150, facets_page: 2)
        .and_return(
          double('SupplejackApi::RecordSearch', facets_hash: { primary_collection: {} })
        )

      get '/v3/metrics/facets.json?'
    end

    it 'returns facets' do
      response_attributes = JSON.parse(response.body)

      expect(response_attributes).to eq(['National Library of New Zealand', 'Radio New Zealand'])
    end
  end

  describe '#global' do
    context 'when no date param is provided' do
      let(:daily_metric) { create(:daily_metrics, date: Time.now.utc.to_date, total_public_sets: 10) }

      before do
        daily_metric
        get '/v3/metrics/global.json?'
      end

      it 'returns current metrics' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq(
          [
            {
              'day' => daily_metric.date.as_json,
              'total_public_sets' => daily_metric.total_public_sets
            }
          ]
        )
      end
    end

    context 'when start and end date param is provided' do
      let(:start_metric) { create(:daily_metrics, created_at: Time.zone.yesterday.to_date.midday, date: Time.zone.yesterday.to_date, total_public_sets: 1) }
      let(:end_metric)   { create(:daily_metrics, date: Time.now.utc.to_date, total_public_sets: 2) }

      before { get "/v3/metrics/global.json?start_date=#{start_metric.created_at.to_date}&end_date=#{end_metric.created_at.to_date}" }

      it 'returns metrics for 2 days' do
        response_attributes = JSON.parse(response.body)

        expect(response_attributes).to eq(
          [
            {
              'day' => start_metric.date.as_json,
              'total_public_sets' => start_metric.total_public_sets
            },
            {
              'day' => end_metric.date.as_json,
              'total_public_sets' => end_metric.total_public_sets
            }
          ]
        )
      end
    end
  end
end
