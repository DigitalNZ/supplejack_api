namespace :index_processor do
  task :run, [:batch_size] => [:environment] do |_, args|
    loop do
      SupplejackApi::IndexProcessor.new(args[:batch_size].to_i).call
      sleep 30
    end
  end
end
