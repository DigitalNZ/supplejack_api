module SupplejackApi
  class StatusLogger < Logger
    def format_message(severity, timestamp, progname, msg)
      "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
    end
  end
end
