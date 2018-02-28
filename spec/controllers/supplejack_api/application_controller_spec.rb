

require 'spec_helper'

module SupplejackApi
  describe ApplicationController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    before(:each) do
      @controller = ApplicationController.new
      allow(@controller).to receive(:render) { nil }
      allow(RecordSchema).to receive(:roles) { { admin: double(:admin, admin: true) } }
    end

    describe '#authenticate_user!' do
      before(:each) do
        allow(@controller).to receive(:params) { { api_key: '12345' } }
        allow(@controller).to receive(:request) { double(:request, ip: '1.1.1.1', format: :json) }
        @user = FactoryBot.create(:user)
        allow(@user).to receive(:update_daily_activity) { nil }
        allow(@controller).to receive(:current_user) { @user }
      end

      it 'should set the current_user' do
        @controller.authenticate_user!
        expect(@controller.current_user).to eq @user
      end

      it 'updates the tracked fields for the user' do
        expect(@user).to receive(:update_tracked_fields)
        @controller.authenticate_user!
      end

      it 'updates the daily activity for the user' do
        expect(@user).to receive(:update_daily_activity)
        @controller.authenticate_user!
      end

      it 'verifies the user limits' do
        expect(@user).to receive(:check_daily_requests)
        @controller.authenticate_user!
      end

      it 'saves the user' do
        expect(@user).to receive(:save)
        @controller.authenticate_user!
      end

      context 'user over daily requests limit' do
        it 'returns a error message' do
          allow(@user).to receive(:over_limit?) { true }
          expect(@controller).to receive(:render).with({ json: { errors: 'You have reached your maximum number of api requests today' }, status: :forbidden })
          @controller.authenticate_user!
        end
      end

      context 'api_key not found' do
        it 'returns a error message' do
          allow(@controller).to receive(:current_user) {  nil }
          expect(@controller).to receive(:render).with({ json: { errors: 'Invalid API Key' }, status: :forbidden})
          @controller.authenticate_user!
        end
      end

      context 'api key not provided' do
        it 'returns a error message' do
          allow(@controller).to receive(:params) {  { api_key: ''} }
          expect(@controller).to receive(:render).with({ json: { errors: 'Please provide a API Key' }, status: :forbidden })
          @controller.authenticate_user!
        end
      end

      context 'wrong format' do
        it 'returns a error message in the default format' do
          allow(@controller).to receive(:params) { {} }
          allow(@controller).to receive(:request) { double(:request, format: :css).as_null_object }
          expect(@controller).to receive(:render).with({ json: { errors: 'Please provide a API Key' }, status: :forbidden })
          @controller.authenticate_user!
        end
      end
    end

    describe "#authenticate_admin!" do
      before {
        allow(@controller).to receive(:request) { double(:request, :ip => "1.1.1.1", :format => :json)}
      }

      it "returns true when the admin authentication was successful" do
        allow(@controller).to receive(:current_user) { double(:user, admin?: true, role: 'admin') }
        expect(@controller.authenticate_admin!).to be_truthy
      end

      it "returns false when the admin authentication was not successful" do
        allow(@controller).to receive(:current_user) { double(:user, admin?: false, role: 'developer') }
        expect(@controller.authenticate_admin!).to be_falsey
      end
    end

    describe "#find_user_set" do
      context "current_user is a admin" do
        before :each do
          @user_set = double(:set).as_null_object
          allow(@controller).to receive(:current_user) { double(:user, admin?: true, role: 'admin').as_null_object }
          allow(@controller).to receive(:params) { {:id => "12345"} }
        end

        it "finds the set even if it's not owned by the current_user" do
          expect(UserSet).to receive(:custom_find).with("12345") { @user_set }
          @controller.find_user_set
        end
      end

      # TODO: Move this to the app
      # context "current_user has dnz role" do
      #   before :each do
      #     @user_set = double(:set).as_null_object
      #     allow(@controller).to receive(:current_user) { double(:user, dnz?: true).as_null_object }
      #     allow(@controller).to receive(:params) { {:id => "12345"} }
      #   end

      #   it "finds the set even if it's not owned by the current_user" do
      #     expect(UserSet).to receive(:custom_find).with("12345") { @user_set }
      #     @controller.find_user_set
      #   end
      # end
    end
  end
end
