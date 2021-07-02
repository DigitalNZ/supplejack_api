# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe Partner do
    describe 'validations' do
      it 'is not valid without a name' do
        partner = Partner.new()
        expect(partner.valid?).to be_falsey
      end
    end
  end

end
