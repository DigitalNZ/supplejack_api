module SupplejackApi
  module ApiRecord
    module Searchable
      extend ActiveSupport::Concern
  
      included do
        include Sunspot::Mongoid
  
        searchable if: :should_index? do
          # **category**: *core*
  
          # text    :attachment_name do
          #   attachment_names
          # end
  
          # string  :internal_identifier
          
          string :source_id do
            primary_fragment.source_id
          end
  
          # string  :has_large_thumbnail_url
          # boolean :available_thumbnail
          # boolean :available_large_thumbnail
  
          # string  :object_name,       multiple: true
  
          # string  :placename,         multiple: true
          # text    :placename do
          #   placename
          # end
          # string  :country,           multiple: true
          # string  :region,            multiple: true
          # location :geo_co_ords do
          #   locations.keep_if do |l|
          #     l.lat.present? and l.lng.present? 
          #   end.first
          # end
          # latlon  :lat_lng,           multiple: true do
          #   locations.keep_if do |l|
          #     l.lat.present? and l.lng.present? 
          #   end
          # end
          # boolean :has_lat_lng do
          #   lat.present? && lng.present?
          # end
          # integer :record_type
  
          # Sets
          # string  :set_id,            multiple: true do
          #   set_ids
          # end
          
          # **category**: *interface*
          Record.build_sunspot_schema(self)
  
          # **category**: *interface*
          boost do
            calculate_boost
          end
        end
  
  
        # Defines the methods *_id and *_text where the Star (*) is replaced by
        # every field in the Authorities, Terms and Other relationships.
        #
        # @example Return a array of values collected from the Authority subcollection
        #   record.name_authority_id => [123, 124]
        #   record.name_authority_text => ["New Zealand", "Wellington"]
        #
        # **category**: *dnz*
        # (Record.authority_fields + Record.relationship_fields).each do |field|
        #   define_method("#{field}_id") do
        #     self.authorities.select{|a| a.name == field.to_s}.map {|auth| auth.authority_id}
        #   end
          
        #   define_method("#{field}_text") do
        #     self.authorities.select{|a| a.name == field.to_s}.map {|auth| auth.text}
        #   end
        # end
        
        # Defines methods to retrieve lom values from the User Contributed Metadata
        # subcollection
        #
        # @example Return a array of values collected from the UcmRecord subcollection
        #
        # **category**: *dnz*
        # Record.lom_fields.each do |field|
        #   define_method("lom_#{field}") do
        #     self.ucm_records.where(name: field).map {|ucm| ucm.value }
        #   end
        # end
  
      end #included
      
      SUNSPOT_TYPE_NAMES = {
        string: :string, 
        integer: :integer, 
        datetime: :time, 
        boolean: :boolean
      }
  
      module ClassMethods
  
        def build_sunspot_schema(builder)
          Schema.fields.each do |name,field|
            options = {}
            search_as = field.search_as || []
  
            value_block = nil
            if field.search_value.present?
              value_block = Proc.new do
                field.search_value.call(self)
              end
            end
  
            options[:as] = field.solr_name if field.solr_name.present?
  
            if search_as.include? :filter
              filter_options = {}
              filter_options[:multiple] = true if field.multi_value.present?
              type = SUNSPOT_TYPE_NAMES[field.type]
  
              builder.public_send(type, field.name, options.merge(filter_options), &value_block)
            end
  
            if search_as.include? :fulltext
              options[:boost] = field.search_boost if field.search_boost.present?
              builder.text field.name, options, &value_block
            end
          end
        end
      
        # **category**: *interface*
        # def valid_facets
        #   facets = [
        #     :content_partner, :display_content_partner, :contributing_partner, :collection, :primary_collection, :category, 
        #     :creator, :contributor, :language, :publisher, :rights, :usage, :tag, :dc_type, :dnz_type, :format, :is_catalog_record,
        #     :is_natlib_record, :date, :published_date, :year, :decade, :century, :subject, :marsden_code, :anzsrc_code,
        #     :library_collection, :internal_identifier, :thesis_level, :eprints_type, :ndha_rights, :is_commercial_use,
        #     :atl_free_download, :atl_purchasable_download
        #   ]
          
        #   Record.authority_fields.each do |field|
        #     facets += ["#{field}_id".to_sym, "#{field}_text".to_sym]
        #   end
          
        #   facets += Record.lom_fields.map {|f| "lom_#{f}".to_sym }
        #   facets
        # end
        
        def valid_groups
          Schema.groups.keys # + [:attachments, :locations, :authorities]
        end
  
        # **category**: *dnz*
        # def problematic_partners
        #   ["mychillybin", "PhotoSales"]
        # end
      end
  
      # **category**: *interface*
      def calculate_boost
        unboostable = self.content_partner & self.class.problematic_partners
        return 0.05 if unboostable.present?
        is_catalog_record ? 1 : 1.1
      end
      
      # **category**: *dnz*
      # def sort_title
      #   title.gsub(/[^A-Za-z0-9 ]/i, "").strip if title.present?
      # end
      
      # ### Location helpers
      #
      # **category**: *core*
      # def placename
      #   locations.map {|l| l.placename}
      # end
      
      # def country
      #   locations.map {|l| l.country}
      # end
      
      # def region
      #   locations.map {|l| l.region}
      # end
      
      # def lat
      #   latitudes = locations.map {|l| l.lat}.compact
      #   latitudes.first
      # end
      
      # def lng
      #   longitudes = locations.map {|l| l.lng}.compact
      #   longitudes.first
      # end
  
      # def set_ids
      #   UserSet.where(:privacy.in => ["public","hidden"], :"set_items.record_id" => self.record_id).map(&:id)
      # end
      
      # def object_name
      #   attachments.map {|a| a.name}
      # end
      
      # **category**: *interface*
      def solr_dates
        return [] unless date
        date.map {|d| Date.parse(d).to_time rescue nil}.compact
      end
      
      # **category**: *dnz*
      # def copy_text_fields(*args)
      #   text = []
      #   args.each do |attribute|
      #     value = self.send(attribute.to_sym)
      #     text << value if value.present?
      #   end
      #   text.flatten.join(" ")
      # end
      
      # **category**: *core*
      # def has_large_thumbnail_url
      #   "Y" if large_thumbnail_url.present?
      # end
  
      # **category**: *core*
      # def available_thumbnail
      #   !!self.thumbnail.try(:available)
      # end
  
      # **category**: *core*
      # def available_large_thumbnail
      #   !!self.large_thumbnail.try(:available)
      # end
      
      # **category**: *dnz*
      # def collection_any_id
      #   collection_parent_id + collection_root_id + collection_mid_id
      # end
      
      # **category**: *core*
      # def attachment_names
      #   attachments.map do |attachment|
      #     attachment.name
      #   end.join " "
      # end
      
      # **category**: *dnz?* *core?* *needs_work*
      # def ndha_rights
      #   attachments.find_all { |a| !a.ndha_rights.nil? }.map(&:ndha_rights).uniq
      # end
      
    end
  end

end
