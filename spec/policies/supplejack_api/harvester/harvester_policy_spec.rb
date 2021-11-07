# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::Harvester::HarvesterPolicy, type: :policy do
  subject(:policy) { described_class }

  let(:story) { create(:story) }

  let(:harvester) { create(:user, role: 'harvester') }
  let(:developer) { create(:user, role: 'developer') }

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
  end
end
