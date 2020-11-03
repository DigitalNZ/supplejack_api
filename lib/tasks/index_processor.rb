require 'rake'

namespace :index_processor do
  task :run, [:batch_size] => [:environment] do |_, args|
    loop do
      if args[:batch_size]
        SupplejackApi::IndexProcessor.new(args[:batch_size].to_i).call
      else
        SupplejackApi::IndexProcessor.new.call
      end
      sleep 30
    end
  end
end
