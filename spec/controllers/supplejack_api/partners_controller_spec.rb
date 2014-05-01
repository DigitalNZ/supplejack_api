require 'spec_helper'

module SupplejackApi
  describe PartnersController do
    routes { SupplejackApi::Engine.routes }

    describe "POST 'create'" do
      it "creates a new partner" do
        Partner.should_receive(:create).with("name" => "Statistics New Zealand").and_call_original
        post :create, partner: FactoryGirl.attributes_for(:partner) 
        response.should be_success
      end

      it "returns the partner" do
        post :create, partner: FactoryGirl.attributes_for(:partner)
        response.body.should include Partner.last.to_json
      end

      context "partner already exists" do
        it "updates the partner" do
          partner = FactoryGirl.create(:partner, name: 'partner1')
          post :create, partner: {_id: partner.id, name: 'partner2'}
          partner.reload
          partner.name.should eq 'partner2'
        end
      end
    end

    describe "GET 'show'" do
      let(:partner) { FactoryGirl.create(:partner) }

      it "finds the partner" do
        Partner.should_receive(:find).with("1")
        get :show, id: 1
      end

      it "returns the partner" do
        Partner.stub(:find) {partner}
        get :show, id: 1
        response.body.should eq partner.to_json
      end
    end

    describe "GET 'index'" do
      let(:partners) { [FactoryGirl.create(:partner), 
                        FactoryGirl.create(:partner, name: "Down to the wire")] }

      it "finds all partners" do
        Partner.should_receive(:all) {partners}
        get :index
      end

      it "returns the partners as a JSON array" do
        Partner.stub(:all) {partners}
        get :index
        response.body.should eq({partners: partners}.to_json)
      end
    end

    describe "PUT 'update'" do
      let(:partner) { FactoryGirl.create(:partner) }

      it "finds and updates the partner" do
        Partner.should_receive(:find).with(partner.id.to_s) {partner}
        partner.should_receive(:update_attributes).with("name" => 'Down to the wire')
        put :update, id: partner.id, partner: {name: 'Down to the wire'}
      end
    end
  end
end
