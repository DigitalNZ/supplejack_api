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

    # Finds and returns a UserSet with id
    #
    # @author Eddie
    # @last_modified Eddie
    # @return [Object] the set_item
    def self.find_by_id(id)
      find(id) rescue nil
    end
  end
end
