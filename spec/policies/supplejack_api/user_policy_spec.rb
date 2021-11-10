# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::UserPolicy, type: :policy do
  subject(:policy) { described_class }

  let(:admin) { create(:admin_user) }
  let(:user)  { create(:user) }

  permissions :show?, :create?, :update?, :destroy? do
    context 'when user is a admin' do
      it 'grants access' do
        expect(policy).to permit(admin)
      end
    end

    context 'when user is not admin' do
      it 'denies access' do
        expect(policy).not_to permit(user)
      end
    end
  end
end
