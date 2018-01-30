require 'spec_helper'

describe ApplicationController, type: :controller do

class DummySearch < BasicObject
  def initialize(results)
    @results = results
  end

  def results
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
end

  before do
    create(:record_with_fragment)
  end

  describe 'GET#index' do
    # TODO: Delete
    context 'Deprecated implementation' do
      it 'creates an interation model when ignore_metrics is not set' do
        get :index
        expect(SupplejackApi::InteractionModels::Record.first.request_type).to eq "search"
      end

      it 'does not create an interaction model when ignore_metrics :true' do
        get :index, params: { ignore_metrics: true }
        expect(SupplejackApi::InteractionModels::Record.count).to eq 0
      end
    end

    context 'RecordMetric implementation' do
      it 'creates an appeared_in_searches RecordMetric for each @record in a @search when ignore_metrics is not set' do
        get :index


      end
    end
  end

  describe 'GET#show' do
    it 'creates an interaction model when ignore_metrics is not set' do
      get :show, params: { id: 1 }
      expect(SupplejackApi::InteractionModels::Record.first.request_type).to eq "get"
    end

    it 'does not create an interaction model when ignore_metrics :true' do
      get :show, params: { id: 1, ignore_metrics: true }
      expect(SupplejackApi::InteractionModels::Record.count).to eq 0
    end
  end
end
