# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Support
    module ValidationLogger
      def self.logger
        logfile = File.open("#{Rails.root}/log/validation.log", 'a')
        logfile.sync = true  # automatically flush data to file
        @logger ||= Logger.new(logfile)
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime.to_formatted_s(:db)}: #{msg}\n"
        end
        @logger
      end
    end
  end
end
