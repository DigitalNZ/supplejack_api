# frozen_string_literal: true

module SupplejackApi
  class UserSet
    include Mongoid::Document
    include Mongoid::Timestamps
    include ActionView::Helpers::SanitizeHelper
    include SupplejackApi::Concerns::UserSet

    # Finds and returns a UserSet with id
    #
    # @author Eddie
    # @last_modified Eddie
    # @return [Object] the set_item
    def self.find_by_id(id)
      where(id: id).first
    end
  end
end
