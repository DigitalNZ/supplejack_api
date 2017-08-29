# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe RecordSerializer do

    before(:each) do
      allow(RecordSchema).to receive(:roles) { double(:developer).as_null_object }
    end

    ## Check functionality but most likely replace with specs that cover the functionality of turning a schema into a serialized record. 

    def serializer(options={}, attributes={})
      record_fields = Record.fields.keys
      record_attributes = Hash[attributes.map {|k,v| [k,v] if record_fields.include?(k.to_s)}.compact]
      attributes.delete_if {|k,v| record_fields.include?(k.to_s) }

      @record = FactoryGirl.build(:record, record_attributes)
      @record.fragments.build(attributes)
      @serializer = RecordSerializer.new(@record, options)
    end

    describe '#as_json' do
      let(:record) { FactoryGirl.build(:record) }
      let(:serializer) { RecordSerializer.new(record) }

      [:next_record, :previous_record, :next_page, :previous_page].each do |attribute|
        it "should include #{attribute} when present" do
          record.send("#{attribute}=", 2)
          expect(serializer.as_json[:record][attribute]).to eq 2
        end

        it "should not include #{attribute} when null" do
          record.send("#{attribute}=", nil)
          expect(serializer.as_json[:record]).to_not have_key(attribute)
        end
      end
    end

    describe '#include_individual_fields!' do
      before { @hash = {} }

      it 'merges in the hash the requested fields' do
        s = serializer({ fields: [:age] }, { age: 22 })
        s.include_individual_fields!(@hash)
        expect(@hash).to eq({ age: 22 })
      end
    end

    describe '#remove_restricted_fields!' do
      let(:hash) { {name: 'John Doe', address: "Wellington", email: ["johndoe@example.com"], age: 30} }
      let(:user) { User.new(role: "developer") }
      let(:restrictions) { { address: {"Wellington"=>["name"], "Auckland"=>["email"]},
                             email: {/example.com/ => ["address", "age"]} } }
      let(:developer_role) { double(:developer_role, field_restrictions: restrictions) }
      let(:admin_role) { double(:admin_role, field_restrictions: nil) }

      before(:each) do
        allow(RecordSchema).to receive(:roles).and_return({ developer: developer_role, admin: admin_role })
      end

      context "string conditions" do
        context "Wellington" do
          let(:s) { serializer({scope: user}, {address: ["Wellington"]}) }

          it "removes name field" do
            s.remove_restricted_fields!(hash)
            expect(hash[:name]).to be_nil
          end

          it "doesn't remove non-restriected fields" do
            s.remove_restricted_fields!(hash)
            expect(hash[:age]).to eq 30
          end
        end

        context "Auckland" do
          let(:s) { serializer({scope: user}, {address: ["Auckland"]}) }

          it "removes email field" do
            s.remove_restricted_fields!(hash)
            expect(hash[:email]).to be_nil
          end
        end
      end

      context "regex conditions" do
        let(:s) { serializer({scope: user}, {email: ["johndoe@example.com"]}) }

        it "removes address field" do
          s.remove_restricted_fields!(hash)
          expect(hash[:address]).to be_nil
        end
      end

      context "remove multiple fields" do
        let(:s) { serializer({scope: user}, {email: ['johndoe@example.com']}) }

        it "removes all fields that match the restrictions" do
          s.remove_restricted_fields!(hash)
          expect(hash[:large_thumbnail_url]).to be_nil
          expect(hash[:thumbnail_url]).to be_nil
        end
      end

      context "field value is empty" do
        let(:s) { serializer({scope: user}, {address: nil}) }

        it "doesn't fail when a string condition field value is empty" do
          s.remove_restricted_fields!(hash)
          expect(hash[:name]).to eq 'John Doe'
        end

        it "doesn't fail when a regex condition field value is empty" do
          s.remove_restricted_fields!(hash)
          expect(hash[:email]).to eq ['johndoe@example.com']
        end
      end

      context "no restrictions for role" do
        let(:admin_user) { User.new(role: "admin") }
        let(:s) { serializer({scope: admin_user}) }

        it "returns all fields" do
          s.remove_restricted_fields!(hash)
          expect(hash.keys).to eq [:name, :address, :email, :age]
        end
      end
    end

    describe '#serializable_hash' do
      context 'include groups of fields' do
        let(:default_group) { double(:default_group, fields: [:name, :email]) }
        let(:details_group) { double(:details_group, fields: [:name, :email, :age]) }
        let(:s) { serializer({groups: [:default]}) }
        let(:record) { double(:record).as_null_object }

        before(:each) do
          @hash = {}
          allow(RecordSchema).to receive(:groups) { {default: default_group, details: details_group} }
          allow(s).to receive(:record) { record }
          allow(s).to receive(:field_value)
        end

        context 'handling groups' do
          it 'should include fields from given group' do
            expect(default_group).to receive(:fields)
            expect(details_group).to_not receive(:fields)
            s.serializable_hash
          end

          it 'should handle non-existent groups' do
            allow(s).to receive(:options) { { groups: [:dogs] } }
            expect(s.serializable_hash.size).to eq 0
          end

          it 'should remove non-existent groups (or field names)' do
            allow(s).to receive(:options) { { groups: [:default, :description] } }
            allow(s).to receive(:field_value).with(:name, anything()) { 'John Doe' }
            expect(s.serializable_hash[:name]).to eq 'John Doe'
          end

          it 'should include fields from multiple groups' do
            allow(s).to receive(:options) { { groups: [:default, :details] } }
            [:name, :email, :age].each do |field|
              expect(s.serializable_hash.keys).to include field
            end
          end
        end

        it 'should remove restricted fields' do
          expect(s).to receive(:remove_restricted_fields!)
          s.serializable_hash
        end

        context 'field/group doesn\'t exist' do
          it 'returns an empty record hash' do
            allow(s).to receive(:options) { { groups: [:dogs] } }
            expect(s.serializable_hash).to be_empty
          end
        end
      end
    end

    describe '#field_restricted?' do
    	let(:s) { serializer({groups: [:default]}) }

  		it 'returns true if the field is restricted' do
  			allow(s).to receive(:field_value) { 'Wellington' }
  			expect(s.send(:field_restricted?, 'address', "Wellington")).to be_truthy
  		end

  		it 'returns false if the field is not restricted' do
  			allow(s).to receive(:field_value) { 'Auckland' }
  			expect(s.send(:field_restricted?, 'address', "Wellington")).to be_falsey
  		end

  		it 'handles multi-value fields' do
  			allow(s).to receive(:field_value) { ['jdoe@test.com', 'johndoe@example.com'] }
  			expect(s.send(:field_restricted?, 'email', /test.com/)).to be_truthy
  		end
    end

    describe "#format_date" do
      let(:s) { serializer({groups: [:default]}) }

      it "returns formated date for a date string" do
        date_time = Time.now
        expect(s.send(:format_date, date_time, "%y/%d/%m")).to eq (date_time.strftime("%y/%d/%m"))
      end
    end

    describe "#field_value" do
      let(:s) { serializer({groups: [:default]}) }
      let(:record) { double(:record, name: 'John Doe', address: nil, email: ['johndoe@example.com', 'jdoe@test.com'], children: ['Sara', 'Bob']) }

      before(:each) do
        allow(s).to receive(:object) { record }
      end

      it "should return the single field value" do
        expect(s.field_value(:name)).to eq 'John Doe'
      end

      it "should return the multipe field value" do
        expect(s.field_value(:email)).to eq ['johndoe@example.com', 'jdoe@test.com']
      end

      it "return nil for nil value" do
        expect(s.field_value(:address)).to be_nil
      end

      context 'search_value defined' do
        context 'field not stored in mongo' do
          it 'uses the value of the search_value block' do
            allow(RecordSchema).to receive(:fields) { { age: double(:field, store: false, search_value: Proc.new{ 21 }) } }
            expect(s.field_value(:age)).to eq 21
          end
        end

        context 'field stored in mongo' do
          it "uses the value from mongo" do
            allow(RecordSchema).to receive(:fields) { {children: double(:field, search_value: Proc.new{1}).as_null_object} }
            expect(s.field_value(:children)).to eq ['Sara', 'Bob']
          end
        end
      end
    end
  end

end
