# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe UserSetSerializer do
    let(:user_set) { create(:user_set_with_set_item) }
    let(:serialized_user_set) { described_class.new(user_set).as_json }

    context 'without passing any options' do
      it 'has :id' do
        expect(serialized_user_set[:id]).to eq user_set.id
      end

      it 'has :name' do
        expect(serialized_user_set[:name]).to eq user_set.name
      end

      it 'has :count' do
        expect(serialized_user_set[:count]).to eq user_set.count
      end

      it 'has :priority' do
        expect(serialized_user_set[:priority]).to eq user_set.priority
      end

      it 'has :featured' do
        expect(serialized_user_set[:featured]).to eq user_set.featured
      end

      it 'has :approved' do
        expect(serialized_user_set[:approved]).to eq user_set.approved
      end

      it 'has :created_at' do
        expect(serialized_user_set[:created_at]).to eq user_set.created_at
      end

      it 'has :updated_at' do
        expect(serialized_user_set[:updated_at]).to eq user_set.updated_at
      end

      it 'has :tags' do
        expect(serialized_user_set[:tags]).to eq user_set.tags
      end

      it 'has :privacy' do
        expect(serialized_user_set[:privacy]).to eq user_set.privacy
      end

      it 'has :subjects' do
        expect(serialized_user_set[:subjects]).to eq user_set.subjects
      end

      it 'has :description' do
        expect(serialized_user_set[:description]).to eq user_set.description
      end

      it 'has record with record_id' do
        expect(serialized_user_set[:record][:record_id]).to eq user_set.record.record_id
      end

      it 'has set items' do
        expect(serialized_user_set[:records]).to eq [{ 'record_id' => user_set.set_items.first.record_id, 'position' => user_set.set_items.first.position }]
      end

      it 'has the :record_id for nested records' do
        expect(serialized_user_set[:records].first).to have_key 'record_id'
      end

      it 'has the :position for nested_records' do
        expect(serialized_user_set[:records].first).to have_key 'position'
      end
    end

    context 'featured records' do
      let(:serialized_feature_set) { described_class.new(user_set, featured: true).as_json }

      it 'has the *featured* record' do
        expect(serialized_feature_set[:records]).not_to be_a(Array)
      end

      it 'has the record_id for the record' do
        expect(serialized_feature_set[:records]).to have_key :record_id
      end

      it 'has the position for the record' do
        expect(serialized_feature_set[:records]).to have_key :position
      end

      describe 'it renders attributes based on your schema :sets group'
      RecordSchema.groups[:sets].fields.each do |field|
        it "has the #{field} field" do
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
          expect(serialized_user_details_set[:user][:name]).to eq user_set.user.name
        end

        it 'does not include the users api key' do
          expect(serialized_user_details_set[:user][:api]).not_to eq user_set.user.api_key
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
            expect(serialized_user_details_set[:user]).to eq user_set.api_key
          end
        end
      end
    end
  end
end
