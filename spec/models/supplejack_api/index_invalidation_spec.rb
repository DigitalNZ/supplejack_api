# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe IndexInvalidation do
    describe '.current_token' do
      it 'creates a new token if none exists' do
        expect(IndexInvalidation.count).to eq(0)

        token = IndexInvalidation.current_token

        expect(token).not_to be_nil
        expect(IndexInvalidation.count).to eq(1)
        expect(token.length).to eq(32) # 16 bytes = 32 hex characters
      end

      it 'returns the existing token if one exists' do
        existing = IndexInvalidation.create

        token = IndexInvalidation.current_token

        expect(token).to eq(existing.token)
        expect(IndexInvalidation.count).to eq(1)
      end
    end

    describe '.update_token' do
      it 'creates a new token if none exists' do
        expect(IndexInvalidation.count).to eq(0)

        token = IndexInvalidation.update_token

        expect(token).not_to be_nil
        expect(IndexInvalidation.count).to eq(1)
      end

      it 'updates the existing token' do
        existing = IndexInvalidation.create
        old_token = existing.token

        new_token = IndexInvalidation.update_token

        expect(new_token).not_to eq(old_token)
        expect(IndexInvalidation.count).to eq(1)
        expect(IndexInvalidation.first.token).to eq(new_token)
      end
    end
  end
end
