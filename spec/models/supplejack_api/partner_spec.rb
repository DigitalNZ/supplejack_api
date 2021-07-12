# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe Partner do
    describe 'validations' do
      it 'is not valid without a name' do
        expect(Partner.new.valid?).to be_falsey
      end
    end
  end
end
