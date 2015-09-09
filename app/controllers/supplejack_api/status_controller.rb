# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  # rubocop:disable Metrics/LineLength
  # FIXME: make log lines smaller
  class StatusController < ApplicationController
    
    skip_before_filter :authenticate_user!, only: [:show]
    skip_before_filter :verify_limits!,     only: [:show]
    around_filter :handle_timeout, only: :show

    newrelic_ignore if defined? NewRelic

    TIMEOUT = 10.seconds

    def show
      begin
        both_ok = Timeout::timeout(TIMEOUT) do
          solr_ok = solr_up?
          mongo_ok = mongod_up?
          solr_ok && mongo_ok
        end
        
        if both_ok
          render status: 200, nothing: true
        else
          render status: 500, nothing: true
        end
      rescue Timeout::Error => e
        Support::StatusLogger.logger.error("Solr or MongoDB is down or took longer than #{TIMEOUT} seconds to respond. Exception is #{e}.\nBacktrace #{e.backtrace[0..2].join("\n")}")
        
        render status: 500, nothing: true
      end
    end

    private

    def handle_timeout
      time = Benchmark.ms { yield }
      Support::StatusLogger.logger.warn("/status request took #{time.round}ms to complete") if time > 5000
    end

    def solr_up?
      begin
        resource = RestClient.get ENV['SOLR_PING'], open_timeout: 5
        success = Hash.from_xml(resource)['response']['str'] == "OK"
        Support::StatusLogger.logger.error("Solr ping command not successful. Ping output: #{Hash.from_xml(resource)['response']}") unless success
        success
      rescue StandardError => e
        Support::StatusLogger.logger.error("Exception when attempting to ping Solr. Exception is #{e}.\nBacktrace #{e.backtrace[0..2].join("\n")}")
        false
      end
    end
    
    def mongod_up?
      begin
        session = Record.collection.database.session
        success = session.command(ping: 1)['ok'] == 1
        Support::StatusLogger.logger.error("MongoDB ping command not successful. Ping output: #{session.command(ping: 1)}") unless success
        success
      rescue StandardError => e
        Support::StatusLogger.logger.error("Exception when attempting to ping MongoDB. Exception is #{e}.\nBacktrace #{e.backtrace[0..2].join("\n")}")
        false
      end    
    end
  end
  # rubocop:enable Metrics/LineLength
end
