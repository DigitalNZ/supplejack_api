# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe SearchParams do
    describe '#cast_param' do
      it 'returns false for "false" string' do
        expect(SearchParams.cast_param('active?', 'false')).to be_falsey
      end

      it 'returns true for "true" string' do
        expect(SearchParams.cast_param('active?', 'true')).to be_truthy
      end

      it 'returns nil if is a "nil" string' do
        expect(SearchParams.cast_param('active?', 'nil')).to be_nil
      end

      it 'returns nil if is a "null" string' do
        expect(SearchParams.cast_param('active?', 'null')).to be_nil
      end

      it 'returns the value unchanged' do
        expect(SearchParams.cast_param('label', 'Black')).to eq('Black')
      end

      it 'should strip any white space' do
        expect(SearchParams.cast_param('label', ' Black Label ')).to eq('Black Label')
      end
    end
  end
end
