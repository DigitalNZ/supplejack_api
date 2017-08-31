# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  # class FakeSet
  #   ATTRIBUTES = [:id, :name, :description, :tags, :count, :privacy]
  #   def initialize(attributes={})
  #     @attributes = attributes
  #   end
  #
  #   def read_attribute_for_serialization(method)
  #     @attributes[method]
  #   end
  #
  #   def method_missing(method, *args, &block)
  #     @attributes[method]
  #   end
  # end
  describe UserSetSerializer do
    let(:user_set) { FactoryGirl.create(:user_set_with_set_item) }
    let(:serialized_user_set) { described_class.new(user_set).as_json }

    context 'without passing any options' do
      it 'returns the :id' do
        expect(serialized_user_set).to have_key :id
      end

      it 'returns the :name' do
        expect(serialized_user_set).to have_key :name
      end

      it 'returns the :count' do
        expect(serialized_user_set).to have_key :count
      end

      it 'returns the :priority' do
        expect(serialized_user_set).to have_key :priority
      end

      it 'returns :featured' do
        expect(serialized_user_set).to have_key :featured
      end

      it 'returns :approved' do
        expect(serialized_user_set).to have_key :approved
      end

      it 'returns :created_at' do
        expect(serialized_user_set).to have_key :created_at
      end

      it 'returns :updated_at' do
        expect(serialized_user_set).to have_key :updated_at
      end

      it 'returns :tags' do
        expect(serialized_user_set).to have_key :tags
      end

      it 'returns :privacy' do
        expect(serialized_user_set).to have_key :privacy
      end

      it 'returns :subjects' do
        expect(serialized_user_set).to have_key :subjects
      end

      it 'returns :description' do
        expect(serialized_user_set).to have_key :description
      end

      it 'returns the record' do
        expect(serialized_user_set[:record]).to have_key :record_id
      end

      it 'returns the set items' do
        expect(serialized_user_set).to have_key :records
      end

      it 'returns the :record_id for nested records' do
        expect(serialized_user_set[:records].first).to have_key 'record_id'
      end

      it 'returns the :position for nested_records' do
        expect(serialized_user_set[:records].first).to have_key 'position'
      end
    end

    context 'featured records' do
      let(:current_user) { U}
      let(:serialized_feature_set) { described_class.new(user_set, featured: true).as_json }

      it 'returns the *featured* record' do
        expect(serialized_feature_set[:records]).not_to be_a(Array)
      end

      it 'it returns the record_id for the record' do
        expect(serialized_feature_set[:records]).to have_key :record_id
      end

      it 'returns the position for the record' do
        expect(serialized_feature_set[:records]).to have_key :position
      end

      describe 'it renders attributes based on your schema :sets group'
      RecordSchema.groups[:sets].fields.each do |field|
        it "renders the #{field} field" do
          expect(serialized_feature_set[:records]).to have_key field
        end
      end
    end

    context 'user information' do
      let(:serialized_user_details_set) { described_class.new(user_set, user: true).as_json }

      context 'as a normal user' do
        # Stubbing didn't work, so this has happened
        before do
          described_class.class_eval {
            define_method :current_user do
              FactoryGirl.create(:user)
            end
          }
        end

        it 'includes the user hash' do
          expect(serialized_user_details_set).to have_key :user
        end

        it 'includes the user name' do
          expect(serialized_user_details_set[:user]).to have_key :name
        end

        it 'does not include the users api key' do
          expect(serialized_user_details_set[:user]).not_to have_key :api_key
        end
      end

      context 'as an admin user' do
        before do
          described_class.class_eval {
            define_method :current_user do
              FactoryGirl.create(:admin_user)
            end
          }

          it 'includes the user api key' do
            expect(serialized_user_details_set[:user]).to have_key :api_key
          end
        end
      end
    end
  end

  # describe UserSetSerializer do
  #   before :each do
  #     @user_set = FactoryGirl.create(:user_set, name: "Dogs and cats", priority: 5)
  #     @user_set.set_items.build(record_id: 1)
  #     @user_set.save
  #   end
  #
  #   context "with user's name" do
  #     before :each do
  #       allow(@user_set).to receive(:user) { double(:user, name: "John", api_key: "12345").as_null_object }
  #     end
  #
  #     it "should include the user's name" do
  #       serializer = UserSetSerializer.new(@user_set, user: true, items: false)
  #       expect(serializer.as_json[:set]).to include({user: {name: "John"}})
  #     end
  #
  #     it "includes the user api key when the user option is an admin" do
  #       allow(RecordSchema).to receive(:roles) { { admin: double(:admin, admin: true) } }
  #       admin = User.new(role: "admin")
  #       serializer = UserSetSerializer.new(@user_set, user: admin, items: false)
  #       expect(serializer.as_json[:set]).to include({user: {name: "John", api_key: "12345"}})
  #     end
  #   end
  #
  #   context "requesting a single item" do
  #     it "should only fetch 1 record" do
  #       serializer = UserSetSerializer.new(@user_set, featured: true, items: false)
  #       expect(@user_set).to receive(:items_with_records).with(1) { [] }
  #       serializer.as_json
  #     end
  #   end
  #
  #   context "not requesting set items" do
  #     it "only returns the name, id, count and priority" do
  #       serializer = UserSetSerializer.new(@user_set, items: false)
  #       expect(serializer.as_json[:set]).to include({id: @user_set.id, name: "Dogs and cats", count: 0, priority: 5})
  #     end
  #
  #     it "includes the set items without extra info" do
  #       serializer = UserSetSerializer.new(@user_set, items: false)
  #       expect(serializer.as_json[:set]).to include({records: [{record_id: 1, position: 1}]})
  #     end
  #   end
  #
  #   context "requesting set items" do
  #     before(:each) do
  #       @user_set = FakeSet.new(id: "1", name: "Dogs and cats", description: "Ugly dogs and cats", tags: ["dog"], count:1, privacy:"hidden", featured: true, approved: true)
  #       allow(@user_set).to receive(:items_with_records){[double(:item, record_id: 5, position: 1, name: "John Smith", address: "Wellington", tag: ['hey']).as_null_object]}
  #       allow(@user_set).to receive(:user) { double(:user, name: "Tony").as_null_object }
  #     end
  #
  #     let(:serializer) { UserSetSerializer.new(@user_set) }
  #
  #     it "returns the full set information" do
  #       expect(serializer.as_json[:set]).to include({id: "1", name: "Dogs and cats", description: "Ugly dogs and cats", tags: ["dog"], count: 1, privacy: "hidden", featured: true, approved: true })
  #     end
  #
  #     it "returns the set items with the records information" do
  #       expect(serializer.as_json[:set][:records]).to eq [{record_id: 5, position: 1, name: "John Smith", address: "Wellington"}]
  #     end
  #
  #     it "returns the user information" do
  #       serializer = UserSetSerializer.new(@user_set, user: true)
  #       expect(serializer.as_json[:set][:user]).to eq({name: "Tony"})
  #     end
  #
  #     it 'does not return the tag field by default' do
  #       serializer = UserSetSerializer.new(@user_set)
  #       expect(serializer.as_json[:set][:records].first).not_to include :tag
  #     end
  #
  #     it 'does return the tag field when it has been requested' do
  #       serializer = UserSetSerializer.new(@user_set, user: true, fields: 'tag')
  #       expect(serializer.as_json[:set][:records].first).to include :tag
  #     end
  #   end
  #
  # end
  #
end
