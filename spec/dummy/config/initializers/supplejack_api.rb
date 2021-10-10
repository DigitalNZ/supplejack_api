SupplejackApi.setup do |config|
  config.log_metrics = true
  config.record_batch_size_for_mongo_queries_and_solr_indexing = 500
end
