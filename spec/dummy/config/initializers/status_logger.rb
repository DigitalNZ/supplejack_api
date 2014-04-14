logfile = File.open("#{Rails.root}/log/status.log", 'a')
logfile.sync = true  # automatically flush data to file
STATUS_LOGGER = SupplejackApi::StatusLogger.new(logfile)