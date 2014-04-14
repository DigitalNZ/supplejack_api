require 'resque/server'
require 'resque_scheduler'
require 'resque_scheduler/server'

Resque::Server.use Rack::Auth::Basic do |username, password|
  username == ENV['RESQUE_USER'] && password == ENV['RESQUE_PASS']
end

Resque.schedule = YAML.load_file(File.join(Rails.root.to_s, 'config/resque_schedule.yml'))

Resque.inline = Rails.env.test?