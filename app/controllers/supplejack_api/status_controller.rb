# frozen_string_literal: true

module SupplejackApi
  # rubocop:disable Metrics/LineLength
  # FIXME: make log lines smaller
  class StatusController < SupplejackApplicationController
    skip_before_action :authenticate_user!, only: [:show], raise: false
    # skip_before_action :verify_limits!,     only: [:show] This devise method doesn't work with rails 5 upgrade.
    # We need find out how this works with the version of devise we are up to.
    around_action :handle_timeout, only: :show

    newrelic_ignore if defined? NewRelic

    TIMEOUT = 10.seconds

    def show
      expires_now
      both_ok = Timeout.timeout(TIMEOUT) do
        solr_ok = solr_up?
        mongo_ok = mongod_up?
        solr_ok && mongo_ok
      end

      if both_ok
        head :ok
      else
        head :internal_server_error
      end
    rescue Timeout::Error => e
      Support::StatusLogger.logger.error("Solr or MongoDB is down or took longer than #{TIMEOUT} seconds to respond. Exception is #{e}.\nBacktrace #{e.backtrace[0..2].join("\n")}")

      head :internal_server_error
    end

    private

    def handle_timeout
      time = Benchmark.ms { yield }
      Support::StatusLogger.logger.warn("/status request took #{time.round}ms to complete") if time > 5000
    end

    def solr_up?
      resource = RestClient.get ENV['SOLR_PING'], open_timeout: 5
      success = Hash.from_xml(resource)['response']['str'] == 'OK'
      unless success
        Support::StatusLogger.logger.error("Solr ping command not successful. Ping output: #{Hash.from_xml(resource)['response']}")
      end
      success
    rescue StandardError => e
      Support::StatusLogger.logger.error("Exception when attempting to ping Solr. Exception is #{e}.\nBacktrace #{e.backtrace[0..2].join("\n")}")
      false
    end

    def mongod_up?
      session = SupplejackApi.config.record_class.collection.database.client
      success = session.command(ping: 1).ok?
      unless success
        Support::StatusLogger.logger.error("MongoDB ping command not successful. Ping output: #{session.command(ping: 1)}")
      end
      success
    rescue StandardError => e
      Support::StatusLogger.logger.error("Exception when attempting to ping MongoDB. Exception is #{e}.\nBacktrace #{e.backtrace[0..2].join("\n")}")
      false
    end
  end
  # rubocop:enable Metrics/LineLength
end
