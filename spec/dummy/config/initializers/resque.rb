# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'resque/server'
require 'resque_scheduler'
require 'resque_scheduler/server'

Resque::Server.use Rack::Auth::Basic do |username, password|
  username == ENV['RESQUE_USER'] && password == ENV['RESQUE_PASS']
end

Resque.schedule = YAML.load_file(File.join(Rails.root.to_s, 'config/resque_schedule.yml'))

Resque.inline = Rails.env.test?