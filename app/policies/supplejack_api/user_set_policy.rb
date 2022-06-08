# frozen_string_literal: true

module SupplejackApi
  class UserSetPolicy
    attr_reader :user, :story

    def initialize(user, story)
      @user = user
      @story = story
    end

    def admin_or_owner?
      @story.user == @user || @user&.admin?
    end

    def admin?
      @user.admin?
    end

    def show?
      return true if admin_or_owner?

      @story.approved? && !@story.private?
    end

    alias index?        admin?
    alias update?       admin_or_owner?
    alias admin_index?  admin?
  end
end
