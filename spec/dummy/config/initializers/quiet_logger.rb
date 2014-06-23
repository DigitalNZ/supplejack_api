# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

# Increase log level for the "/status" url to prevent logging spam 
# as this url is accessed very often on UAT

Rails::Rack::Logger.class_eval do
  def call_with_quiet_logger(env)
    old_logger_level, level = Rails.logger.level, Logger::ERROR
    
    Rails.logger.level = level if env['PATH_INFO'].start_with?('/status')
    call_without_quiet_logger(env)

  ensure

    Rails.logger.level = old_logger_level
  end
  alias_method_chain :call, :quiet_logger
end