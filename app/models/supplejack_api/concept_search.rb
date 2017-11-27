# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class ConceptSearch < Search
    def initialize(options = {})
      @options = options.dup
      @options.merge!(
        and: {},
        or: {},
        without: {},
        page: 1,
        per_page: 20,
        sort: nil,
        direction: 'desc',
        fields: ConceptSchema.model_fields.keys.join(','),
        debug: nil
      )
    end

    # FIXME: make me smaller!
    def search_builder
      @search_builder ||= Sunspot.new_search(SupplejackApi::Concept) do
        spellcheck collate: true, only_more_popular: true if options[:suggest]

        options[:without].each do |name, values|
          values = values.split(',')
          values.each do |value|
            without(name, to_proper_value(name, value))
          end
        end

        if options[:geo_bbox]
          coords = options[:geo_bbox].split(',').map(&:to_f)
          with(:lat_lng).in_bounding_box([coords[2], coords[1]], [coords[0], coords[3]])
        end

        adjust_solr_params do |params|
          if options[:solr_query].present?
            params[:q] ||= ''
            params['q.alt'] = options[:solr_query]
            params[:defType] = 'dismax'
          end
        end

        order_by(sort, direction) if options[:sort].present?

        paginate page: page, per_page: per_page
      end

      @search_builder.build(&build_conditions)
      @search_builder
    end
    # rubocop:enable Metrics/MethodLength

    def query_fields
      query_fields_list = super
      query_fields_list += %i[name label] if (query_fields_list && %i[name label]).present?
    end

    def field_list
      return @field_list if @field_list
      model_fields = ConceptSchema.model_fields.dup
      valid_fields = model_fields.keep_if { |_key, field| field.try(:store).nil? }

      @field_list = options[:fields].split(',').map { |f| f.strip.tr(':', '_').to_sym }
      @field_list.keep_if do |f|
        valid_fields.include?(f)
      end

      @field_list
    end

    def group_list
      return @group_list if @group_list
      @group_list = options[:fields].split(',').map { |f| f.strip.to_sym }
      @group_list.keep_if { |f| ConceptSchema.groups.keys.include?(f) }
      @group_list
    end
  end
end
