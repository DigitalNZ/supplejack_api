# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe SourceAuthoritySerializer do
    let(:source_authorty) { create(:source_authority) }
    let(:serialized_source_authority) { described_class.new(source_authorty).as_json }

    describe 'schema attributes' do
      it 'has @type' do
        expect(serialized_source_authority['@type']).to eq source_authorty.concept_type
      end

      ConceptSchema.fields.each_key do |field|
        it "has #{field} field" do
          expect(serialized_source_authority).to have_key field
        end
      end
    end
  end
end
