# Any directory globs added here will automatically be required
# so their constants can be accessed without first directly accessing them
#
# This is used by the MetricsApi to automatically load presenters
directories_to_eager_load = [
  ['app', 'services', 'metrics_api', 'v3', 'presenters', '**']
].map{|x| SupplejackApi::Engine.root.join(*x)}

directories_to_eager_load.each do |path|
  Dir.glob(path).each{|constant| require constant}
end
