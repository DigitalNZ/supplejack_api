# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe SourceAuthoritySerializer do
    let(:source_authorty) { FactoryGirl.create(:source_authority) }
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
