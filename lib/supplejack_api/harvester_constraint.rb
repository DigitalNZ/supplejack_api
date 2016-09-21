# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class HarvesterConstraint
    def initialize
      @ips = ENV['HARVESTER_IPS'].gsub(/\s+/, '').split(',')
    rescue
      # Allow supplejack:install generator to work without application.yml file
      @ips = ['127.0.0.1']
    end

    def matches?(request)
      forwarded_ips(request).each { |ip| return false unless @ips.include?(ip) }
      @ips.include?(request.remote_ip)
    end

    def forwarded_ips(request)
      ip_addresses = request.env['HTTP_X_FORWARDED_FOR']
      ip_addresses ? ip_addresses.strip.split(/[,\s]+/) : []
    end
  end
end
