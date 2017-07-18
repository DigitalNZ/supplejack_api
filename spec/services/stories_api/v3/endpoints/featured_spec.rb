# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      RSpec.describe Featured do

        describe '#get' do

          context 'successful request' do
            let(:response) { Featured.new.get }
            before do
              record = create(:record)
              story_item = create(:embed_dnz_item, id: record.record_id)
              stories = create_list(:story, 4, featured: true, privacy: 'public')
              allow_any_instance_of(SupplejackApi::UserSet).to receive(:records).and_return(story_item)
            end

            it 'returns a 200 status code' do
              expect(response[:status]).to eq(200)
            end

            it 'returns an array of all of a users stories if the user exists' do
              payload = response[:payload]

              expect(payload.length).to eq 4
            end

            it 'returns a payload of hashes with the correct keys' do
              payload = response[:payload]
              fields = [:name, :id, :cover_thumbnail, :creator]

              payload.each do |story|
                fields.each do |field|
                  expect(story.include? field).to be true
                end
              end
            end

          end
        end
      end
    end
  end
end
