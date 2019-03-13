SupplejackApi.setup do |config|
  config.record_class = SupplejackApi::Record
  config.preview_record_class = SupplejackApi::PreviewRecord
  config.log_metrics = true
  config.record_batch_size_for_mongo_queries_and_solr_indexing = 500
end
