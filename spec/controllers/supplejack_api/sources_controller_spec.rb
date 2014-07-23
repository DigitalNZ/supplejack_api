# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe SourcesController do
    routes { SupplejackApi::Engine.routes }

    let(:partner) { FactoryGirl.create(:partner) }

    describe 'POST "create"' do
      it 'creates a new source' do
        Source.should_receive(:create).with('name' => 'Sample source', 'source_id' => '1234', "partner_id" => partner.id.to_s)
        post :create, partner_id: partner, source: FactoryGirl.attributes_for(:source)
        response.should be_success
      end

      it 'returns the source' do
        post :create, partner_id: partner, source: FactoryGirl.attributes_for(:source)
        partner.reload
        response.body.should include Source.last.to_json
      end

      context "source all ready exists" do
        it "updates the source" do
          source = partner.sources.create(FactoryGirl.attributes_for(:source, name: "source_1"))
          post :create, partner_id: partner, source: {_id: source.id, name: 'source2'}
          source.reload
          source.name.should eq 'source2'
        end
      end
    end

    describe 'GET "show"' do
      before(:each )do
        Source.create(FactoryGirl.attributes_for(:source))
      end

      it 'assigns the source' do
        get :show, id: Source.last
        assigns(:source).should eq Source.last
      end

      it 'returns the source' do
        get :show, id: Source.last
        response.body.should include Source.last.to_json
      end
    end

    describe 'GET "index"' do
      let(:sources) { [FactoryGirl.build(:source)] }

      it 'assigns all sources' do
        Source.should_receive(:all) { sources }
        get :index
        assigns(:sources).should eq sources
      end

      it 'returns all sources' do
        Source.should_receive(:all) { sources }
        get :index
        response.body.should include sources.to_json
      end

      context "search" do

        let(:suppressed_source) { FactoryGirl.build(:source)  }

        it "searches the sources if params source is defined" do
          Source.should_receive(:where).with("status" => "suppressed") { [suppressed_source] }
          get :index, source: { status: "suppressed" }
        end
      end
    end

    describe 'PUT "update"' do
      let(:source) { FactoryGirl.create(:source) }

      it 'finds and update source' do
        put :update, id: source.id, source: {status: "suppressed"}
        assigns(:source).status.should eq 'suppressed'
      end

      it 'returns the source' do
        put :update,id: source.id, source: {status: "suppressed"}
        response.body.should include 'suppressed'
      end
    end

    describe 'GET "reindex"' do

      before(:each) do
        @source = Source.create(FactoryGirl.attributes_for(:source))
      end

      it "enqueues the job with the source_id and date if given" do
        date = Time.now
        Resque.should_receive(:enqueue).with(IndexSourceWorker, @source.source_id, date.to_s)
        get :reindex, id: @source.id, date: date
      end

    end

    describe 'GET "link_check_records"' do
      let(:records) { [ double(:record, source_url: 'http://1'), 
                        double(:record, source_url: 'http://2'), 
                        double(:record, source_url: 'http://3'), 
                        double(:record, source_url: 'http://4')] }

      let(:source) { FactoryGirl.build(:source) }

      before do
        controller.stub(:first_two_records).with(anything,:oldest) {records[0..1]}
        controller.stub(:first_two_records).with(anything,:latest) {records[2..3]}
        Source.stub(:find) { source }
      end

      it "should asign the oldest two records by syndication_date" do
        controller.should_receive(:first_two_records).with(source.source_id,:oldest) {records[0..1]}
        get :link_check_records, id: source.id
        assigns(:records).should include('http://1', 'http://2')
      end

      it "should asign the latest two records by syndication_date" do
        controller.should_receive(:first_two_records).with(source.source_id,:latest) {records[2..3]}
        get :link_check_records, id: source.id
        assigns(:records).should include('http://3', 'http://4')
      end
    end

    describe "#first_two_records" do
      let(:asc_relation) {double(:asc_relation)} 
      let(:sorted_relation) {double(:sorted_relation)} 

      let(:records) { [ double(:record, source_url: 'http://1'), 
                        double(:record, source_url: 'http://2'), 
                        double(:record, source_url: 'http://3'), 
                        double(:record, source_url: 'http://4')] }

      before do
        Record.should_receive(:where).with({"fragments.source_id" => "tapuhi", :status => 'active'}) { asc_relation }
        sorted_relation.should_receive(:limit).with(2) { records[0..1] }
      end

      it "should get the oldest two records by syndication_date" do
        asc_relation.should_receive(:sort).with("fragments.syndication_date" => 1) { sorted_relation }
        controller.send(:first_two_records, 'tapuhi', :oldest).should eq (records[0..1])
      end

      it "should get the latest two records by syndication_date" do
        asc_relation.should_receive(:sort).with("fragments.syndication_date" => -1) { sorted_relation }
        controller.send(:first_two_records, 'tapuhi', :latest).should eq (records[0..1])
      end
    end
  end
end