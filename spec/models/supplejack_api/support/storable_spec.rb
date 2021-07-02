# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  module Support
    describe Storable do
      let(:record) { FactoryBot.create(:record, record_id: 1234, internal_identifier: "nlnz:1234") }
      let(:source) { record.sources.create }
      
    end
  end
end
