# frozen_string_literal: true# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Stories
    class ModerationsController < ApplicationController

      respond_to :json
      before_action :authenticate_admin!

      def show
        @user_sets = UserSet.public_sets(page: params[:page])
        render json: serializable_array(@user_sets, user: true, total: true).to_json
      end

      private

      def serializable_array(user_sets, options = {})
        options.reverse_merge!(root: false, items: false, user: false, total: false)
        hash = { 'sets' => [] }
        user_sets.each do |set|
          hash['sets'] << StoriesModerationSerializer.new(set, options).as_json
        end
        hash['total'] = UserSet.public_sets_count if options[:total]
        hash
      end
    end
  end
end
