# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe Concept do
    let(:concept) { create(:concept) }

    subject { concept }

    it { should be_timestamped_document }
    it { should be_stored_in :concepts }
    it { should be_timestamped_document.with(:created) }
    it { should be_timestamped_document.with(:updated) }
    
  end
end
