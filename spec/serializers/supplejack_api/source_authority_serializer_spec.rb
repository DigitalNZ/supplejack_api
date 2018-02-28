

require 'spec_helper'

module SupplejackApi
  describe SourceAuthoritySerializer do
    let(:source_authorty) { FactoryBot.create(:source_authority) }
    let(:serialized_source_authority) { described_class.new(source_authorty).as_json }

    describe 'it renders attributes based off of your schema' do
      it 'includes the @type field' do
        expect(serialized_source_authority).to have_key '@type'
      end

      ConceptSchema.fields.keys.each do |field|
        it "includes the #{field} field" do
          expect(serialized_source_authority).to have_key field
        end
      end
    end
  end
end
