# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe UserSetSerializer do
    let(:user_set) { create(:user_set_with_set_item) }
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
      let(:current_user) { U }
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
          described_class.class_eval do
            define_method :current_user do
              FactoryBot.create(:user)
            end
          end
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
          described_class.class_eval do
            define_method :current_user do
              FactoryBot.create(:admin_user)
            end
          end

          it 'includes the user api key' do
            expect(serialized_user_details_set[:user]).to have_key :api_key
          end
        end
      end
    end
  end
end
