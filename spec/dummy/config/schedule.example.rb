# Use this file to define when/how often the API background jobs should run.
# This is an example file that will not work without adding the "whenever" gem to your API project
# If you wish to use another scheduling system you can use this as a basis

set :environment, :development if Rails.env.development?
set :output, {:error => 'log/whenever.stderr.log', :standard => 'log/whenever.stdout.log'}

every '*/5 * * * *' do
  runner 'supplejackapi::interactionmetricsworker.perform_async'
end

every '*/5 * * * *' do
  runner 'supplejackapi::clearindexbuffer.perform_async'
end

every '57 23 * * *' do
  runner 'supplejackapi::dailymetricsworker.perform_async'
end

every '30 23 * * *' do
  runner 'supplejackapi::storeuseractivityworker.perform_async'
end
