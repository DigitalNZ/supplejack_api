# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe StatusController do
    routes { SupplejackApi::Engine.routes }

    let(:logger) { double(:logger).as_null_object }

    before do
      Support::StatusLogger.stub(:logger) { logger }
    end

    describe "GET 'status'" do
      it "returns a '200' HTTP status if both Solr and Mongo are up and running" do
        controller.stub(:solr_up?).and_return(true)
        controller.stub(:mongod_up?).and_return(true)
        
        get :show
        response.status.should == 200
      end
      
      it "returns a '500' HTTP response if Solr is down" do
        controller.stub(:solr_up?).and_return(false)
        controller.stub(:mongod_up?).and_return(true)
        
        get :show
        response.status.should == 500
      end
      
      it "returns a '500' http response if Mongo is down" do
        controller.stub(:solr_up?).and_return(true)
        controller.stub(:mongod_up?).and_return(false)
        
        get :show
        response.status.should == 500
      end

      it "logs an error message when the status call takes a long time" do
        controller.stub(:solr_up?).and_raise(Timeout::Error)
        
        logger.should_receive(:error)
        get :show
      end
    end
    
    describe "#solr_up?" do
      it "returns true when solr is up and running" do
        ok_xml_string = <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <response>
            <str name="status">OK</str>
          </response>
        EOF
          
        RestClient.stub(:get) { ok_xml_string }
          
        controller.send(:solr_up?).should be_true
      end

      it "returns false when solr is running but failing" do
        failed_xml_string = <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <response>
            <str name="status">NOK</str>
          </response>
        EOF
        RestClient.stub(:get) { failed_xml_string }
        
        controller.send(:solr_up?).should be_false
      end

      context "solr is down" do
        before(:each) do
          RestClient.stub(:get).and_raise(StandardError)
        end

        it "returns false" do
          controller.send(:solr_up?).should be_false
        end

        it "should log an error" do
          logger.should_receive(:error)
          controller.send(:solr_up?)
        end
      end
    end
    
    describe "#mongod_up?" do
      it "returns true when mongod is up and running" do
        Record.stub_chain(:collection, :database, :session).and_return(session).as_null_object
        session.should_receive(:command).with(ping: 1).and_return({"ok" => 1})
        
        controller.send(:mongod_up?).should be_true
      end

      context "mongod is down" do
        before(:each) do
          Record.stub_chain(:collection, :database, :session).and_return(session).as_null_object
          session.should_receive(:command).with(ping: 1).and_return(nil)
        end

        it "returns false" do
          controller.send(:mongod_up?).should be_false
        end

        it "should log an error" do
          logger.should_receive(:error)
          controller.send(:mongod_up?)
        end
      end
    end
  end
end