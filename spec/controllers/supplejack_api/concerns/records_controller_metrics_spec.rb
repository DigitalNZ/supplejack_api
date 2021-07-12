# frozen_string_literal: true

require 'spec_helper'

describe ApplicationController, type: :controller do
  # rubocop:disable Lint/ConstantDefinitionInBlock
  class DummySearch < BasicObject
    def initialize(results)
      @results = results
    end

    def records
      @results
    end

    def valid?
      true
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock

  controller do
    include SupplejackApi::Concerns::RecordsControllerMetrics

    def index
      @search = DummySearch.new(SupplejackApi.config.record_class.all.to_a)
      head :ok
    end

    def show
      @record = SupplejackApi.config.record_class.first
      head :ok
    end

    def source
      @record = SupplejackApi.config.record_class.first
      head :ok
    end
  end

  before do
    create_list(:record_with_fragment, 3)
    routes.draw do
      get 'source' => 'anonymous#source'
      get 'index' => 'anonymous#index'
      get 'show' => 'anonymous#show'
    end
  end

  describe 'GET#index' do
    it 'creates an appeared_in_searches ::RequestMetric for each @record in a @search when ignore_metrics is not set' do
      get :index

      record_ids = SupplejackApi.config.record_class.all.map(&:record_id)
      collections = SupplejackApi.config.record_class.all.map(&:display_collection)

      expect(SupplejackApi::RequestMetric.count).to eq 1
      expect(SupplejackApi::RequestMetric.first.metric).to eq 'appeared_in_searches'
      expect(SupplejackApi::RequestMetric.first.records.map { |x| x['record_id'] }).to eq record_ids

      expect(SupplejackApi::RequestMetric.first.records.map { |x| x['display_collection'] }).to eq collections
    end

    it 'does not create an appeared_in_searches SupplejackApi::RequestMetric when ignore_metrics is set' do
      get :index, params: { ignore_metrics: true }
      expect(SupplejackApi::RequestMetric.count).to eq 0
    end
  end

  describe 'GET#show' do
    it 'creates a page_views SupplejackApi::RequestMetric when ignore_metrics is not set' do
      get :show, params: { id: 1 }
      expect(SupplejackApi::RequestMetric.count).to eq 1
      expect(SupplejackApi::RequestMetric.first.records).to eq [{ 'record_id' => 1, 'display_collection' => 'test' }]
      expect(SupplejackApi::RequestMetric.first.metric).to eq 'page_views'
    end

    it 'does not create a page_views SupplejackApi::RequestMetric when ignore_metrics is not set' do
      get :show, params: { id: 1, ignore_metrics: true }
      expect(SupplejackApi::RequestMetric.count).to eq 0
    end
  end

  describe 'GET#source' do
    it 'creates a source_clickthrough SupplejackApi::RequestMetric' do
      get :source
      expect(SupplejackApi::RequestMetric.count).to eq 1
      expect(SupplejackApi::RequestMetric.first.records).to eq [{ 'record_id' => 1, 'display_collection' => 'test' }]
      expect(SupplejackApi::RequestMetric.first.metric).to eq 'source_clickthroughs'
    end
  end
end
