# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require "spec_helper"

module SupplejackApi
  describe RecordSerializer do

    before(:each) do
      Schema.stub(:roles) { double(:developer).as_null_object }
    end

    def record_hash(attributes={}, method=nil, options={})
      record_fields = Record.fields.keys
      record_attributes = Hash[attributes.map {|k,v| [k,v] if record_fields.include?(k.to_s)}.compact]
      attributes.delete_if {|k,v| record_fields.include?(k.to_s) }
    
      @record = FactoryGirl.build(:record, record_attributes)
      @record.fragments.build(attributes)
      @serializer = RecordSerializer.new(@record, options)
      
      if method
        @serializer.send(method)
      else
        @serializer.as_json[:record]
      end
    end
    
    def serializer(options={}, attributes={})
      record_fields = Record.fields.keys
      record_attributes = Hash[attributes.map {|k,v| [k,v] if record_fields.include?(k.to_s)}.compact]
      attributes.delete_if {|k,v| record_fields.include?(k.to_s) }
    
      @record = FactoryGirl.build(:record, record_attributes)
      @record.fragments.build(attributes)
      @serializer = RecordSerializer.new(@record, options)
    end
    
    describe "#as_json" do
      let(:record) { FactoryGirl.build(:record) }
      let(:serializer) { RecordSerializer.new(record) }
  
      [:next_record, :previous_record, :next_page, :previous_page].each do |attribute|
        it "should include #{attribute} when present" do
          record.send("#{attribute}=", 2)
          serializer.as_json[:record][attribute].should eq 2
        end
        
        it "should not include #{attribute} when null" do
          record.send("#{attribute}=", nil)
          serializer.as_json[:record].should_not have_key(attribute)
        end
      end
    end
    
    describe "#include_individual_fields!" do
    	pending 'Discuss if this method is still valid'
      # before(:each) do
      #   @hash = {}
      # end
      
      # it "should merge in the hash the requested fields" do
      #   s = serializer({fields: [:atl_purchasable]}, {atl_purchasable: true})
      #   s.include_individual_fields!(@hash)
      #   @hash.should eq({atl_purchasable: true})
      # end
    end
    
    describe "#remove_restricted_fields!" do
      let(:hash) { {name: 'John Doe', address: "Wellington", email: ["johndoe@example.com"], age: 30} }
      let(:user) { User.new(role: "developer") }
      let(:restrictions) { { address: {"Wellington"=>["name"], "Auckland"=>["email"]}, 
                             email: {/example.com/ => ["address", "age"]} } }
      let(:developer_role) { double(:developer_role, field_restrictions: restrictions) }
      let(:admin_role) { double(:admin_role, field_restrictions: nil) }

      before(:each) do
        Schema.stub(:roles).and_return({ developer: developer_role, admin: admin_role })
      end
    
      context "string conditions" do
        context "Wellington" do
          let(:s) { serializer({scope: user}, {address: ["Wellington"]}) }

          it "removes name field" do
            s.remove_restricted_fields!(hash)
            hash[:name].should be_nil
          end

          it "doesn't remove non-restriected fields" do
            s.remove_restricted_fields!(hash)
            hash[:age].should eq 30
          end
        end

        context "Auckland" do
          let(:s) { serializer({scope: user}, {address: ["Auckland"]}) }

          it "removes email field" do
            s.remove_restricted_fields!(hash)
            hash[:email].should be_nil
          end
        end
      end

      context "regex conditions" do
        let(:s) { serializer({scope: user}, {email: ["johndoe@example.com"]}) }

        it "removes address field" do
          s.remove_restricted_fields!(hash)
          hash[:address].should be_nil
        end
      end

      context "remove multiple fields" do
        let(:s) { serializer({scope: user}, {email: 'johndoe@example.com'}) }

        it "removes all fields that match the restrictions" do
          s.remove_restricted_fields!(hash)
          hash[:large_thumbnail_url].should be_nil
          hash[:thumbnail_url].should be_nil
        end
      end

      context "field value is empty" do
        let(:s) { serializer({scope: user}, {address: nil}) }

        it "doesn't fail when a string condition field value is empty" do
          s.remove_restricted_fields!(hash)
          hash[:name].should eq 'John Doe'
        end

        it "doesn't fail when a regex condition field value is empty" do
          s.remove_restricted_fields!(hash)
          hash[:email].should eq ['johndoe@example.com']
        end
      end

      context "no restrictions for role" do
        let(:admin_user) { User.new(role: "admin") }
        let(:s) { serializer({scope: admin_user}) }
        
        it "returns all fields" do
          s.remove_restricted_fields!(hash)
          hash.keys.should eq [:name, :address, :email, :age]
        end
      end
    end
    
    describe "#serializable_hash" do
      context "include groups of fields" do
        let(:default_group) { double(:default_group, fields: [:name, :email]) }
        let(:details_group) { double(:details_group, fields: [:name, :email, :age]) }
        let(:s) { serializer({groups: [:default]}) }
        let(:record) { double(:record).as_null_object }
  
        before(:each) do
          @hash = {}
          Schema.stub(:groups) { {default: default_group, details: details_group} }
          s.stub(:record) { record }
          s.stub(:field_value)
        end
        
        context "handling groups" do
          it "should include fields from given group" do
            default_group.should_receive(:fields)
            details_group.should_not_receive(:fields)
            s.serializable_hash
          end
  
          it "should handle non-existent groups" do
            s.stub(:options) { { groups: [:dogs] } }
            s.serializable_hash.size.should eq 0
          end
  
          it "should remove non-existent groups (or field names)" do
            s.stub(:options) { { groups: [:default, :description] } }
            s.stub(:field_value).with(:name, anything()) { 'John Doe' }
            s.serializable_hash[:name].should eq 'John Doe'
          end
  
          it 'should include fields from multiple groups' do
            s.stub(:options) { { groups: [:default, :details] } }
            [:name, :email, :age].each do |field|
              s.serializable_hash.keys.should include field
            end         
          end
        end 
  
        it "should remove restricted fields" do
          s.should_receive(:remove_restricted_fields!)
          s.serializable_hash
        end
  
        context "field/group doesn't exist" do
          it "returns an empty record hash" do
            s.stub(:options) { { groups: [:dogs] } }
            s.serializable_hash.should be_empty
          end
        end
      end
    end

    describe '#field_restricted?' do
    	let(:s) { serializer({groups: [:default]}) }

  		it 'returns true if the field is restricted' do
  			s.stub(:field_value) { 'Wellington' }
  			expect(s.send(:field_restricted?, 'address', "Wellington")).to be_true
  		end

  		it 'returns false if the field is not restricted' do
  			s.stub(:field_value) { 'Auckland' }
  			expect(s.send(:field_restricted?, 'address', "Wellington")).to be_false
  		end

  		it 'handles multi-value fields' do
  			s.stub(:field_value) { ['jdoe@test.com', 'johndoe@example.com'] }
  			expect(s.send(:field_restricted?, 'email', /test.com/)).to be_true
  		end
    end
  
    describe "#field_value" do
      let(:s) { serializer({groups: [:default]}) }
      let(:record) { double(:record, name: 'John Doe', address: nil, email: ['johndoe@example.com', 'jdoe@test.com'], children: ['Sara', 'Bob']) }
  
      before(:each) do
        s.stub(:object) { record }
      end
  
      it "should return the single field value" do
        s.field_value(:name).should eq 'John Doe'
      end
  
      it "should return the multipe field value" do
        s.field_value(:email).should eq ['johndoe@example.com', 'jdoe@test.com']
      end
  
      it "return nil for nil value" do
        s.field_value(:address).should be_nil
      end
  
      context "search_value defined" do
        context "field not stored in mongo" do
          it "uses the value of the search_value block" do
            Schema.stub(:fields) { {age: double(:field, store:false, search_value: Proc.new{21})} }
            s.field_value(:age).should eq 21
          end
        end
  
        context "field stored in mongo" do
          it "uses the value from mongo" do
            Schema.stub(:fields) { {children: double(:field, search_value: Proc.new{1}).as_null_object} }
            s.field_value(:children).should eq ['Sara', 'Bob']
          end
        end
      end
    end
  end

end
