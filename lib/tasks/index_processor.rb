# frozen_string_literal: true

require 'rake'

namespace :index_processor do
  task :run, [:batch_size] => [:environment] do |_, args|
    batch_size = args.fetch(:batch_size, 500).to_i

    loop do
      SupplejackApi::IndexProcessor.new(batch_size).call
      sleep 30
    end
  end
end
