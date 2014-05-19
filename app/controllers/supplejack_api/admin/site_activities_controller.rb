# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
	module Admin
	  class SiteActivitiesController < BaseController
	    
	    respond_to :html
	    respond_to :csv, only: :index

	    def index
	      @site_activities = SiteActivity.sortable(order: params[:order], page: params[:page])
	    end
	  end
	end
end