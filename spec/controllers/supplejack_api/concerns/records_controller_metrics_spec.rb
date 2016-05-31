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
    render nothing: true
  end

  def show
    @record = SupplejackApi::Record.first
    render nothing: true
  end
end

  before do
    create(:record_with_fragment)
  end

  describe 'GET#index' do
    it 'creates an interation model when ignore_metrics is not set' do
      get :index
      expect(SupplejackApi::InteractionModels::Record.first.request_type).to eq "search"
    end

    it 'does not create an interaction model when ignore_metrics :true' do
      get :index, ignore_metrics: true
      expect(SupplejackApi::InteractionModels::Record.count).to eq 0
    end
  end

  describe 'GET#show' do
    it 'creates an interaction model when ignore_metrics is not set' do
      get :show, id: 1
      expect(SupplejackApi::InteractionModels::Record.first.request_type).to eq "get"
    end

    it 'does not create an interaction model when ignore_metrics :true' do
      get :show, id: 1, ignore_metrics: true
      expect(SupplejackApi::InteractionModels::Record.count).to eq 0
    end
  end
end
