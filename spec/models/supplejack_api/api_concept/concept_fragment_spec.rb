# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  module ApiConcept
    describe ConceptFragment do
  
      let!(:concept) { FactoryGirl.build(:concept_with_fragment) }
    
      before { concept.save }

      describe 'schema_class' do
      	it 'should return ConceptSchema' do
      		expect(ConceptFragment.schema_class).to eq ConceptSchema
      	end
      end
    
      
    end
  end
end
