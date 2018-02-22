# frozen_string_literal: true



module SupplejackApi
  module Support
    module ValidationLogger
      def self.logger
        logfile = File.open(Rails.root.join('log', 'validation.log'), 'a')
        logfile.sync = true  # automatically flush data to file
        @logger ||= Logger.new(logfile)
        @logger.formatter = proc do |_severity, datetime, _progname, msg|
          "#{datetime.to_formatted_s(:db)}: #{msg}\n"
        end
        @logger
      end
    end
  end
end
