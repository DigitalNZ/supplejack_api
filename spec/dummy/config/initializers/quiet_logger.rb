

# Increase log level for the "/status" url to prevent logging spam
# as this url is accessed very often on UAT

module Quiet
  def self.call(env)
    old_logger_level, level = Rails.logger.level, Logger::ERROR

    Rails.logger.level = level if env['PATH_INFO'].start_with?('/status')
    call_without_quiet_logger(env)

  ensure

    Rails.logger.level = old_logger_level
  end
end

Rails::Rack::Logger.class_eval do
  prepend Quiet
  # alias_method_chain :call, :quiet_logger
end