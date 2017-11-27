# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
