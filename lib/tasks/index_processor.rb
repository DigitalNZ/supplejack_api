# frozen_string_literal: true

require 'rake'

namespace :index_processor do
  task :run, [:batch_size] => [:environment] do |_, args|

    mem = GetProcessMem.new
    puts "Before the loop do #{mem.mb}"

    loop do
      puts "start the loop do #{mem.mb}"
      fork do
        SupplejackApi::IndexProcessor.new.call
      end

      Process.wait

      puts "Process finished, sleeping.."
      sleep 30
    end

    puts "After the loop do #{mem.mb}"
  end
end
