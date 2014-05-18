# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

logfile = File.open("#{Rails.root}/log/status.log", 'a')
logfile.sync = true  # automatically flush data to file
STATUS_LOGGER = SupplejackApi::StatusLogger.new(logfile)