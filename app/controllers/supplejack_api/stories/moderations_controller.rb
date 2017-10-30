# frozen_string_literal: true

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

      def index
        @user_sets = UserSet.all_public_sets
        request.env['HTTP_ACCEPT_ENCODING'] = 'gzip'
        render json: @user_sets, each_serializer: StoriesModerationSerializer,
               root: 'sets', adapter: :json
      end
    end
  end
end
