require 'spec_helper'

describe ApplicationController, type: :controller do

class DummySearch < BasicObject
  def initialize(results)
    @results = results
  end

  def results
    @results
  end

  def records
    @results
  end

  def valid?
    true
  end
end

controller do
  include SupplejackApi::Concerns::RecordsControllerMetrics

  def index
    @search = DummySearch.new(SupplejackApi::Record.all.to_a)
    head :ok
  end

  def show
    @record = SupplejackApi::Record.first
    head :ok
  end

  def source
    @record = SupplejackApi::Record.first
    head :ok
  end
end

  before do
    create_list(:record_with_fragment, 3)
    routes.draw do
      get 'source' => "anonymous#source"
      get 'index' => 'anonymous#index'
      get 'show' => 'anonymous#show'
    end
  end

  describe 'GET#index' do
    it 'creates an interation model when ignore_metrics is not set' do
      get :index
      expect(SupplejackApi::InteractionModels::Record.first.request_type).to eq "search"
    end

    it 'does not create an interaction model when ignore_metrics :true' do
      get :index, params: { ignore_metrics: true }
      expect(SupplejackApi::InteractionModels::Record.count).to eq 0
    end

    it 'creates an appeared_in_searches SupplejackApi::RecordMetric for each @record in a @search when ignore_metrics is not set' do
      get :index
      expect(SupplejackApi::RecordMetric.count).to eq SupplejackApi::Record.count
      expect(SupplejackApi::RecordMetric.all.map(&:appeared_in_searches)).to eq [1, 1, 1]
    end

    it 'does not create an appeared_in_searches SupplejackApi::RecordMetric when ignore_metrics is set' do
      get :index, params: { ignore_metrics: true }
      expect(SupplejackApi::RecordMetric.count).to eq 0
    end
  end

  describe 'GET#show' do
    it 'creates an interaction model when ignore_metrics is not set' do
      get :show, params: { id: 1 }
      expect(SupplejackApi::InteractionModels::Record.first.request_type).to eq "get"
    end

    it 'creates a page_views SupplejackApi::RecordMetric when ignore_metrics is not set' do
      get :show, params: { id: 1 }
      expect(SupplejackApi::RecordMetric.count).to eq 1
      expect(SupplejackApi::RecordMetric.last.page_views).to eq 1
    end

    it 'does not create an interaction model when ignore_metrics :true' do
      get :show, params: { id: 1, ignore_metrics: true }
      expect(SupplejackApi::InteractionModels::Record.count).to eq 0
    end

    it 'does not create a page_views SupplejackApi::RecordMetric when ignore_metrics is not set' do
      get :show, params: { id: 1, ignore_metrics: true }
      expect(SupplejackApi::RecordMetric.count).to eq 0
    end
  end

  describe 'GET#source' do
    it 'creates a source_clickthrough SupplejackApi::RecordMetric' do
      get :source
      expect(SupplejackApi::RecordMetric.count).to eq 1
      expect(SupplejackApi::RecordMetric.first.source_clickthroughs).to eq 1
    end
  end
end
