# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class ConceptSerializer < ActiveModel::Serializer

    has_many :source_authorities

    CORE_FIELDS = %w(@context @type @id)

    def source_authorities?
      return false if (options[:groups]).blank?
      return concept.try(options[:groups]).try(:any?)
    end

    def serializable_hash
      hash = attributes
      # Create empty context block to add to once we know what fields we have.
      hash['@context'] = {}
      hash['@type'] = concept.send(:@type)
      hash['@id'] = concept.site_id

      include_individual_fields!(hash)
      include_context_fields!(hash)
      include!(:source_authorities, :node => hash)
      hash
    end

    def include_context_fields!(hash)
      fields = hash.dup
      fields.delete_if { |field| !ConceptSchema.model_fields.include?(field) }

      if self.options[:inline_context]
        hash['@context'] = Concept.build_context(fields.keys)
      else
        hash['@context'] = concept.context
      end
      hash
    end

    def include_individual_fields!(hash)
      if self.options[:fields].present?
        self.options[:fields].push(:concept_id)
        self.options[:fields].sort!
        self.options[:fields].each do |field|
          hash[field] = concept.send(field)
        end
      end
      hash
    end
  end
end
