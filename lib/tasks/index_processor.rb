# frozen_string_literal: true

require 'rake'

namespace :index_processor do
  task run: :environment do
    loop do
      fork do
        SupplejackApi::IndexProcessor.new.call
      end

      Process.wait

      sleep 30
    end
  end
end
