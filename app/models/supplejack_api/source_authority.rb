# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class SourceAuthority
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Attributes::Dynamic

    # TODO: Move this to a class/module that store all the constants
    MONGOID_TYPE_NAMES = {
      string: String,
      integer: Integer,
      datetime: DateTime,
      boolean: Boolean
    }.freeze

    store_in collection: 'source_authorities'

    field :concept_type,                       type: String
    field :internal_identifier,         type: String
    field :concept_score,               type: Integer
    field :source_id,                   type: String
    field :source_name,                 type: String
    field :url,                         type: String

    # TODO: Add field validations

    belongs_to :concept, class_name: 'SupplejackApi::Concept'

    ConceptSchema.fields.each do |name, field|
      next if field.store == false
      type = field.multi_value.presence ? Array : MONGOID_TYPE_NAMES[field.type]
      field name, type: type
    end
  end
end
