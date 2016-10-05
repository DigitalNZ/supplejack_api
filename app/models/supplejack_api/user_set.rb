# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class UserSet
    include Mongoid::Document
    include Mongoid::Timestamps
    include ActionView::Helpers::SanitizeHelper
    include ActiveModel::MassAssignmentSecurity
    include SupplejackApi::Concerns::UserSet

    def self.find_by_id(id)
      where(id: id).first
    end

    # Finds a set item and returns it
    #
    # @author Eddie
    # @last_modified Eddie
    # @param id [String] the id
    # @return [SetItem] the item
    def find_set_item_by_id(id)
      self.set_items.where(id: id).first
    end
  end
end
