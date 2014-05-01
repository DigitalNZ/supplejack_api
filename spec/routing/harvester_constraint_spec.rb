require 'spec_helper'

module SupplejackApi
  describe HarvesterConstraint do
    let(:constraint) { HarvesterConstraint.new }
    
    describe "#forwarded_ips" do
      it "returns a single ip address in the X-FORWARDED-FOR header" do
        request = double(:request, :env => {"HTTP_X_FORWARDED_FOR" => "192.122.171.246"})
        constraint.forwarded_ips(request).should eq ["192.122.171.246"]
      end
      
      it "returns multiple ip addresses in the X-FORWARDED-FOR header" do
        request = double(:request, :env => {"HTTP_X_FORWARDED_FOR" => "192.122.171.246, 192.122.171.234"})
        constraint.forwarded_ips(request).should eq ["192.122.171.246", "192.122.171.234"]
      end
      
      it "returns multiple ip addresses in the X-FORWARDED-FOR header without spaces" do
        request = double(:request, :env => {"HTTP_X_FORWARDED_FOR" => "192.122.171.246,192.122.171.234"})
        constraint.forwarded_ips(request).should eq ["192.122.171.246", "192.122.171.234"]
      end
    end
    
    describe "#matches?" do
      context "forwarded_ips is empty" do
        it "returns true when the remote_ip is one of the allowed ips" do
          request = double(:request, :env => {"HTTP_X_FORWARDED_FOR" => nil}, :remote_ip => "127.0.0.1")
          constraint.matches?(request).should be_true
        end
        
        it "returns false when the remote_ip is not allowed" do
          request = double(:request, :env => {"HTTP_X_FORWARDED_FOR" => nil}, :remote_ip => "192.1.1.1")
          constraint.matches?(request).should be_false
        end
      end
      
      context "with some forwarded_ips" do
        it "returns true when the remote_ip and the forwarded_ips are allowed" do
          request = double(:request, :env => {"HTTP_X_FORWARDED_FOR" => "192.1.1.0"}, :remote_ip => "193.1.1.0")
          constraint.instance_variable_set("@ips", ["192.1.1.0", "193.1.1.0"])
          constraint.matches?(request).should be_true
        end
        
        it "returns false when the remote_ip is not allowed" do
          request = double(:request, :env => {"HTTP_X_FORWARDED_FOR" => "192.1.1.0"}, :remote_ip => "222.1.1.0")
          constraint.instance_variable_set("@ips", ["192.1.1.0", "193.1.1.0"])
          constraint.matches?(request).should be_false
        end
        
        it "returns false when any of the forwarded_ips are not allowed" do
          request = double(:request, :env => {"HTTP_X_FORWARDED_FOR" => "192.1.1.0, 222.1.1.0"}, :remote_ip => "193.1.1.0")
          constraint.instance_variable_set("@ips", ["192.1.1.0", "193.1.1.0", "194.1.1.0"])
          constraint.matches?(request).should be_false
        end
        
      end
    end
  end
end