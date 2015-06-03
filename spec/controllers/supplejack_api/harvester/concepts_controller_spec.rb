# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require "spec_helper"

module SupplejackApi
  describe Harvester::ConceptsController, type: :controller do
    # routes { SupplejackApi::Engine.routes }

    # let(:concept) { FactoryGirl.build(:concept) }

    # describe "POST create" do
    #   before(:each) do
    #     allow(Concept).to receive(:find_or_initialize_by_identifier) { concept }
    #   end

    #   context "preview is false" do
    #     it "finds or initializes a concept by identifier" do
    #       expect(Concept).to receive(:find_or_initialize_by_identifier).with("internal_identifier" => "1234") { concept }
    #       post :create, concept: {internal_identifier: "1234"}
    #       expect(assigns(:concept)).to eq concept
    #     end
    #   end

    #   context "preview is true" do
    #     it "finds or initializes a preview record by identifier" do
    #       expect(PreviewRecord).to receive(:find_or_initialize_by_identifier).with("internal_identifier" => "1234") { concept }
    #       post :create, concept: {internal_identifier: "1234"}, preview: true
    #       expect(assigns(:concept)).to eq concept
    #     end
    #   end
    # end

    # describe "PUT update" do
    #   let(:concept) { double(:concept).as_null_object }

    #   before do
    #     allow(Concept).to receive(:custom_find) { concept }
    #   end

    #   it 'finds the record and assigns it' do
    #     expect(Concept).to receive(:custom_find).with('123', nil, {status: :all}) { concept }
    #     put :update, id: 123, concept: { status: 'supressed' }, format: :json
    #     expect(assigns(:concept)).to eq(concept)
    #   end

    #   it "updates the status of the record" do
    #     expect(concept).to receive(:update_attribute).with(:status, 'supressed')
    #     put :update, id: 123, concept: { status: 'supressed' }, format: :json
    #   end
    # end
  end
end
