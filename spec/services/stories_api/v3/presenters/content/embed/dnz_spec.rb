module StoriesApi
  module V3
    module Presenters
      module Content
        module Embed
          RSpec.describe Dnz do
            let(:record) {create(:record)}
            let(:block) {create(:embed_dnz_item, id: record.id)}
            let(:result) {subject.call(block)}

            it 'presents the fields under the :record field' do
              expect(result).to have_key(:record)
            end

            it 'includes the record_id as a top level field' do
              expect(result).to have_key(:record_id)
            end

            it 'presents the record fields' do
              [:id, :title, :display_collection, :category, :image_url, :tags].each do |key|
                expect(result[:record]).to have_key(key)
              end
            end

            it 'presents them from the correct record' do
              expect(result[:record][:title]).to eq(record.title)
            end
          end
        end
      end
    end
  end
end
