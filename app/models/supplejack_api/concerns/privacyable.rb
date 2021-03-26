# frozen_string_literal: true

# Fields, validations, scopes and callbacks relating to the privacy of
# the user_sets/stories
module SupplejackApi
  module Concerns
    module Privacyable
      extend ActiveSupport::Concern

      included do
        field :privacy, type: String,   default: 'public'

        validates :privacy, inclusion: { in: %w[public hidden private] }
        before_validation :set_default_privacy

        # can't add this scope without breaking the model
        # it must be an existing method in Mongoid
        # scope :public,              -> { publicly_viewable }
        scope :publicly_viewable,     -> { where(privacy: 'public') }
        scope :hidden,                -> { where(privacy: 'hidden') }
        scope :private,               -> { where(privacy: 'private') }
        scope :public_or_hidden,      -> { self.in(privacy: %w[public hidden]) }
        scope :public_not_favourites, -> { where(privacy: 'public', :name.ne => 'Favourites') }
        scope :all_public_sets,       -> { public_not_favourites.order(updated_at: :desc) }

        def public_or_hidden?
          public? || hidden?
        end

        def public?
          privacy == 'public'
        end

        def hidden?
          privacy == 'hidden'
        end

        def private?
          privacy == 'private'
        end
      end
    end
  end
end
