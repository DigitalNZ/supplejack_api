module SupplejackApi::Concerns::SearchSerializable
  extend ActiveSupport::Concern

  included do
    def serializable_hash
      hash = {}
      hash[:result_count] = object.total
      hash[:results] = records_serialized_array
      hash[:per_page] = object.per_page
      hash[:page] = object.page
      hash[:request_url] = object.request_url
      hash[:solr_request_params] = object.solr_request_params if object.solr_request_params
      hash[:warnings] = object.warnings if object.warnings.present?
      hash[:suggestion] = object.collation if object.options[:suggest]
      hash
    end

    def records_serialized_array
      args = {fields: object.field_list, groups: object.group_list, scope: object.scope}
      ActiveModel::ArraySerializer.new(object.results, args)
    end
  end
end
