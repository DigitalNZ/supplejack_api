# frozen_string_literal: true

require 'rake'

namespace :index_processor do
  task :run, [:batch_size] => [:environment] do |_, args|
    Signal.trap('TERM') do
      Rails.logger.info "Graceful shutdown PID=#{Process.pid}"
      exit 0
    end
    batch_size = args.fetch(:batch_size, 500).to_i

    loop do
      fork do
        SupplejackApi::IndexProcessor.new(batch_size).call
      rescue StandardError => e
        Rails.logger.error(e)
      end
      Rails.logger.info "Finished forks #{Process.waitall}"
      sleep 30
    end
  end
end
