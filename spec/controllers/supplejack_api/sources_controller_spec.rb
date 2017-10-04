# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe SourcesController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    let(:partner) { FactoryGirl.create(:partner) }

    describe 'POST "create"' do
      it 'creates a new source' do
        expect(Source).to receive(:create).with('name' => 'Sample source', 'source_id' => '1234', "partner_id" => partner.id.to_s)
        post :create, partner_id: partner, source: FactoryGirl.attributes_for(:source)
        expect(response).to be_success
      end

      it 'returns the source' do
        post :create, partner_id: partner, source: FactoryGirl.attributes_for(:source)
        partner.reload
        expect(response.body).to include Source.last.to_json
      end

      context "source all ready exists" do
        it "updates the source" do
          source = partner.sources.create(FactoryGirl.attributes_for(:source, name: "source_1"))
          post :create, partner_id: partner, source: {_id: source.id, name: 'source2'}
          source.reload
          expect(source.name).to eq 'source2'
        end
      end
    end

    describe 'GET "show"' do
      before(:each )do
        Source.create(FactoryGirl.attributes_for(:source))
      end

      it 'assigns the source' do
        get :show, id: Source.last
        expect(assigns(:source)).to eq Source.last
      end

      it 'returns the source' do
        get :show, id: Source.last
        expect(response.body).to include Source.last.to_json
      end
    end

    describe 'GET "index"' do
      let(:sources) { [FactoryGirl.build(:source)] }

      it 'assigns all sources' do
        expect(Source).to receive(:all) { sources }
        get :index
        expect(assigns(:sources)).to eq sources
      end

      it 'returns all sources' do
        expect(Source).to receive(:all) { sources }
        get :index
        expect(response.body).to include sources.to_json
      end

      it 'presents the sources in a top level node' do
        get :index
        expect(JSON.parse(response.body)['sources']).to eq []
      end

      context "search" do

        let(:suppressed_source) { FactoryGirl.build(:source)  }

        it "searches the sources if params source is defined" do
          expect(Source).to receive(:where).with("status" => "suppressed") { [suppressed_source] }
          get :index, source: { status: "suppressed" }
        end
      end
    end

    describe 'PUT "update"' do
      let(:source) { FactoryGirl.create(:source) }

      it 'finds and update source' do
        put :update, id: source.id, source: {status: "suppressed"}
        expect(assigns(:source).status).to eq 'suppressed'
      end

      it 'returns the source' do
        put :update,id: source.id, source: {status: "suppressed"}
        expect(response.body).to include 'suppressed'
      end
    end

    describe 'GET "reindex"' do

      before(:each) do
        @source = Source.create(FactoryGirl.attributes_for(:source))
      end

      it "enqueues the job with the source_id and date if given" do
        date = Time.now
        expect(IndexSourceWorker).to receive(:perform_async).with(@source.source_id, date.to_s)
        get :reindex, id: @source.id, date: date
      end

    end

    describe 'GET "link_check_records"' do
      let(:records) { [ double(:record, landing_url: 'http://1'),
                        double(:record, landing_url: 'http://2'),
                        double(:record, landing_url: 'http://3'),
                        double(:record, landing_url: 'http://4')] }

      let(:source) { FactoryGirl.build(:source, source_id: 'source_name') }

      before do
        allow(Source).to receive(:find) { source }
        allow(source).to receive(:random_records) { records }
      end

      it "should call the random records methid for source with 4" do
        expect(source).to receive(:random_records).with(4)

        get :link_check_records, id: source.id
      end

      it "should asign the oldest two records by syndication_date" do
        get :link_check_records, id: source.id

        expect(response.body).to eq "[\"http://1\",\"http://2\",\"http://3\",\"http://4\"]"
      end
    end
  end
end
