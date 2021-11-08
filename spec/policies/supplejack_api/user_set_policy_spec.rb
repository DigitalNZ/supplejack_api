# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::UserSetPolicy, type: :policy do
  subject(:policy) { described_class }

  let(:story) { create(:story) }
  let(:admin) { create(:admin_user) }
  let(:user) { create(:user) }

  permissions :show? do
    context 'when the story is private' do
      let(:story) { create(:story, privacy: 'private') }

      context 'when user is the owner of the story' do
        let(:user) { story.user }

        it 'grants access' do
          expect(policy).to permit(user, story)
        end
      end

      context 'when user is an admin' do
        it 'grants access' do
          expect(policy).to permit(admin, story)
        end
      end

      context 'when user is not and admin or owner of story' do
        it 'denies access' do
          expect(policy).not_to permit(user, story)
        end
      end
    end

    context 'when the story is public' do
      let(:story) { create(:story, privacy: 'public') }

      context 'when user is not and admin or owner of story' do
        it 'grants access' do
          expect(policy).to permit(user, story)
        end
      end
    end
  end

  permissions :update? do
    context 'when user is the owner of the story' do
      let(:user) { story.user }

      it 'grants access' do
        expect(policy).to permit(user, story)
      end
    end

    context 'when user is an admin' do
      it 'grants access' do
        expect(policy).to permit(admin, story)
      end
    end

    context 'when user is not and admin or owner of story' do
      it 'denies access' do
        expect(policy).not_to permit(user, story)
      end
    end
  end

  permissions :admin_index? do
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
