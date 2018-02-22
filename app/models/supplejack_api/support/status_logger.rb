# frozen_string_literal: true

module SupplejackApi
  module Support
    module StatusLogger
      def self.logger
        logfile = File.open(Rails.root.join('log', 'status.log'), 'a')
        logfile.sync = true
        @logger ||= Logger.new(logfile)
        @logger.formatter = proc do |_severity, datetime, _progname, msg|
          "#{datetime.to_formatted_s(:db)} #{msg}\n"
        end
        @logger
      end
    end
  end
end
