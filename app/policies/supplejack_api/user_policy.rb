# frozen_string_literal: true

module SupplejackApi
  class UserPolicy
    attr_reader :requester, :user

    def initialize(requester, user)
      @user = user
      @requester = requester
    end

    def admin?
      @requester&.admin?
    end

    alias show?    admin?
    alias create?  admin?
    alias update?  admin?
    alias destroy? admin?
  end
end
