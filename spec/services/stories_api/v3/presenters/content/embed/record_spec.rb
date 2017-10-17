module StoriesApi
  module V3
    module Presenters
      module Content
        module Embed
          RSpec.describe Record do
            let(:record) {create(:record_with_fragment)}
            let(:block) {create(:embed_dnz_item, id: record.record_id)}
            let(:result) {subject.call(block)}

            context 'record_id' do
              it 'includes it as a top level field' do
                expect(result).to have_key(:id)
              end

              it 'is an Integer' do
                expect(result[:id]).to be_an Integer
              end
            end

            context 'fields with non matching names' do
              it 'converts the custom field name to the respective field on the record' do
                expect(result[:image_url]).to eq(record.large_thumbnail_url)
              end
            end

            it 'presents the record fields' do
              [:title, :display_collection, :category, :image_url, :landing_url, :tags, :content_partner, :creator, :contributing_partner, :rights].each do |key|
                expect(result).to have_key(key)
              end
            end

            it 'presents them from the correct record' do
              expect(result[:title]).to eq(record.title)
            end

            context 'no large_thumbnail_url' do
              let(:record) {create(:record_with_no_large_thumb)}
              let(:block) {create(:embed_dnz_item, id: record.record_id)}
              let(:result) {subject.call(block)}

              it 'presents thumbnail_url if there is no large_thumbnail_url' do

                expect(result[:image_url]).to eq record.thumbnail_url
              end
            end

            context 'no title' do
              let(:record) { create(:record, title: nil) }
              let(:block) {create(:embed_dnz_item, id: record.record_id)}
              let(:result) {subject.call(block)}

              it 'says Untitled if the title is nil' do
                expect(result[:title]).to eq 'Untitled'
              end
            end
          end
        end
      end
    end
  end
end
