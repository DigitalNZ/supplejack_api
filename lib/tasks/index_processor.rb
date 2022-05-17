# frozen_string_literal: true

require 'rake'

namespace :index_processor do
  task :run, [:batch_size] => [:environment] do |_, args|
    batch_size = args.fetch(:batch_size, 500).to_i

    loop do
      fork { SupplejackApi::IndexProcessor.new(batch_size).call }
      Process.wait
      sleep 30
    end
  end
end
