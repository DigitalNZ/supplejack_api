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

    def show?
      return true unless @story.private?

      @story.user == @user || @user&.admin?
    end

    def admin_index?
      @user.admin?
    end

    alias update? admin_or_owner?
  end
end
