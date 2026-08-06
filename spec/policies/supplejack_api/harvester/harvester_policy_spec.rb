# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::Harvester::HarvesterPolicy, type: :policy do
  subject(:policy) { described_class }

  let(:harvester) { create(:harvest_user) }
  let(:developer) { create(:user) }
  let(:read_only) { create(:read_only_harvest_user) }
  let(:admin)     { create(:admin_user) }

  permissions :index?, :show?, :create?, :update?, :destroy?, :delete?, :flush?, :reindex?, :link_check_records? do
    context 'when user is a harvester' do
      it 'grants access' do
        expect(policy).to permit(harvester)
      end
    end

    context 'when user is not harvester' do
      it 'denies access' do
        expect(policy).not_to permit(developer)
      end
    end

    context 'when user has a read only harvester role' do
      it 'denies access' do
        expect(policy).not_to permit(read_only)
      end
    end
  end

  permissions :harvester_read_only? do
    it 'grants access to a read only harvester role' do
      expect(policy).to permit(read_only)
    end

    it 'grants access to an admin role' do
      expect(policy).to permit(admin)
    end

    it 'grants access to a full harvester role' do
      expect(policy).to permit(harvester)
    end

    it 'denies access to a developer role' do
      expect(policy).not_to permit(developer)
    end
  end
end
