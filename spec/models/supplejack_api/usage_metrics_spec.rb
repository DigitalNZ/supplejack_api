# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe UsageMetrics do
  	let(:search_request_logs) { [FactoryGirl.build(:request_log, request_type: "search", log_values: ['Voyager 1', 'Explorer 1'], id: 1),
            									   FactoryGirl.build(:request_log, request_type: "search", log_values: ['Light Sail', 'Sputnik'], id: 2),
            									   FactoryGirl.build(:request_log, request_type: "search", log_values: ['Voyager 1', 'Sputnik'], id: 3)
            									   ] }

    let(:get_request_logs) { [FactoryGirl.build(:request_log, request_type: "get", log_values: ['Luna 6', 'Light Sail'], id: 4),
                              FactoryGirl.build(:request_log, request_type: "get", log_values: ['Light Sail', 'CubeSat'], id: 5),
                              FactoryGirl.build(:request_log, request_type: "get", log_values: ['Sputnik', 'Luna 6'], id: 6)
                              ] }

    let(:user_set_request_logs) { [FactoryGirl.build(:request_log, request_type: "user_set", log_values: ['Apollo 11', 'Explorer 1'], id: 7),
                                  FactoryGirl.build(:request_log, request_type: "user_set", log_values: ['Light Sail', 'CubeSat'], id: 8),
                                  FactoryGirl.build(:request_log, request_type: "user_set", log_values: ['Sputnik', 'Apollo 11'], id: 9)
                                 ] }                         

    describe "build_hash_for" do
      
      describe "for searches requests" do
        before(:each) do
          SupplejackApi::RequestLog.stub(:where) { search_request_logs }
        end

        it "should find serach logs" do
          SupplejackApi::RequestLog.should_receive(:where).with(request_type: "search")
          SupplejackApi::UsageMetrics.build_hash_for("search")
        end

        it "should return hash of counts and request_log ids" do
          expect(SupplejackApi::UsageMetrics.build_hash_for("search")).to eq [
                                                                                {:"Voyager 1" => 2, 
                                                                                 :"Explorer 1" => 1,
                                                                                 :"Light Sail" => 1,
                                                                                 :Sputnik => 2}, 
                                                                                 [1, 2, 3]
                                                                              ]
        end
      end

      describe "for get requests" do
        before(:each) do
          SupplejackApi::RequestLog.stub(:where) { get_request_logs }
        end

        it "should find get logs" do
          SupplejackApi::RequestLog.should_receive(:where).with(request_type: "get")
          SupplejackApi::UsageMetrics.build_hash_for("get")
        end

        it "should return hash of counts and request_log ids" do
          expect(SupplejackApi::UsageMetrics.build_hash_for("get")).to eq [
                                                                            {:"Luna 6" => 2,
                                                                             :"Light Sail" => 2,
                                                                             :CubeSat => 1,
                                                                             :Sputnik => 1}, 
                                                                             [4, 5, 6]
                                                                          ]
        end        
      end

      describe "for view user set requests" do
        before(:each) do
          SupplejackApi::RequestLog.stub(:where) { user_set_request_logs }
        end

        it "should find user set logs" do
          SupplejackApi::RequestLog.should_receive(:where).with(request_type: "user_set")
          SupplejackApi::UsageMetrics.build_hash_for("user_set")
        end

        it "should return hash of counts and request_log ids" do
          expect(SupplejackApi::UsageMetrics.build_hash_for("user_set")).to eq [
                                                                                  {:"Apollo 11" => 2,
                                                                                   :"Explorer 1" => 1,
                                                                                   :"Light Sail" => 1,
                                                                                   :CubeSat=>1,
                                                                                   :Sputnik=>1},
                                                                                   [7, 8, 9]
                                                                                ]
        end         
      end

    end

    describe "build_metrics" do
      before(:each) do
        allow(SupplejackApi::UsageMetrics).to receive(:build_hash_for).with("search").and_return([
                                                                                {:"Voyager 1" => 10},
                                                                                [1, 2, 3]
                                                                              ])

        allow(SupplejackApi::UsageMetrics).to receive(:build_hash_for).with("get").and_return([
                                                                            {:"Voyager 1" => 8},
                                                                            [4, 5, 6]
                                                                          ])
        
        allow(SupplejackApi::UsageMetrics).to receive(:build_hash_for).with("user_set").and_return([
                                                                                  {:"Voyager 1" => 2},
                                                                                  [7, 8, 9]
                                                                                ])
        SupplejackApi::RequestLog.stub(:find) { FactoryGirl.build(:request_log, request_type: "search", log_values: ['Voyager 1', 'Explorer 1'], id: 1) }
        SupplejackApi::UsageMetrics.stub(:where) { [] }
      end

      it "should build_hash_for search, get and user_set" do
        SupplejackApi::UsageMetrics.should_receive(:build_hash_for).with("get")
        SupplejackApi::UsageMetrics.should_receive(:build_hash_for).with("search")
        SupplejackApi::UsageMetrics.should_receive(:build_hash_for).with("user_set")
        SupplejackApi::UsageMetrics.should_receive(:where)
        SupplejackApi::UsageMetrics.build_metrics
      end

      it "should create usage metrics entries" do
        SupplejackApi::UsageMetrics.should_receive(:create).with({:record_field_value=>"Voyager 1", :searches=>10, :gets=>8, :user_set_views=>2, :total=>20, day: Date.current}).at_least(:once)
        SupplejackApi::UsageMetrics.build_metrics
      end

      it "should update usage metrics entry when it already exist for the field value" do
        SupplejackApi::UsageMetrics.stub(:where) { [ FactoryGirl.build(:usage_metrics, :record_field_value=>"Voyager 1", :searches=>10, :gets=>8, :user_set_views=>2, :total=>20) ] }
        SupplejackApi::UsageMetrics.any_instance.should_receive(:update).with({:searches=>20, :gets=>16, :user_set_views=>4, :total=>40}).at_least(:once)
        SupplejackApi::UsageMetrics.build_metrics
      end           
    end

  end
end
