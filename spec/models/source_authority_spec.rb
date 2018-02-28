

require 'spec_helper'

module SupplejackApi
  describe SourceAuthority do
    let(:source_authority) { create(:source_authority) }

    subject { source_authority }

    # it { should be_stored_in :source_authorities }
    # it { should be_timestamped_document }
    # it { should be_timestamped_document.with(:created) }
    # it { should be_timestamped_document.with(:updated) }

    # it { should belong_to(:concept) }

    describe 'fields' do
      context '.model fields' do
        %w(concept_type internal_identifier concept_score source_id source_name url).each do |field|
          it "responds to #{field} field" do
            expect(source_authority.respond_to?(field)).to be_truthy
          end
        end
      end

      context '.schema fields' do
        ConceptSchema.fields.each do |name, field|
          it "sets the #{name} field from the schema" do
            expect(source_authority.respond_to?(name)).to be_truthy
          end
        end
      end
    end

  end
end
