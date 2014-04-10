module SupplejackApi
  module ApiRecord
    module FragmentHelpers
  
      extend ActiveSupport::Concern
  
      included do
        embeds_many :fragments, class_name: 'SupplejackApi::Fragment', cascade_callbacks: true
        embeds_one :merged_fragment, class_name: 'SupplejackApi::Fragment'
  
        before_save :merge_fragments
      end
  
      def primary_fragment(attributes={})
        primary = self.fragments.where(priority: 0).first
        primary ? primary : self.fragments.build(attributes.merge(priority: 0))
      end
  
      def primary_fragment!(attributes={})
        self.primary_fragment(attributes).tap {|s| s.save }
      end
  
      def merge_fragments
        self.merged_fragment = nil
  
        if self.fragments.size > 1
          self.merged_fragment = Fragment.new
  
          Fragment.mutable_fields.each do |name, field_type|
            if field_type == Array
              values = Set.new
              deletions = []
              sorted_fragments.each do |s| 
                values += (Array(s.public_send(name)) - deletions) 
              end
              self.merged_fragment.public_send("#{name}=", values.to_a)
            else
              values = sorted_fragments.to_a.map {|s| s.public_send(name) }
              self.merged_fragment.public_send("#{name}=", values.compact.first)
            end
          end
        end
      end
  
      def method_missing(symbol, *args, &block)
        type = Fragment.mutable_fields[symbol.to_s]
        if self.merged_fragment
          value = self.merged_fragment.public_send(symbol)
        elsif self.fragments.first
          value = self.fragments.first.public_send(symbol)
        end
        (type == Array) ? Array(value) : value
      end
  
      def fragment_many_relations(name)
        if name == :authorities
          merge_authorities
        else
          objects = []
          sorted_fragments.each {|s| objects += s.public_send(name) }
          objects
        end
      end
  
      def fragment_one_relations(name)
        values = sorted_fragments.to_a.map {|f| f.public_send(name) }
        values.compact.first
      end
  
      def sorted_fragments
        self.fragments.sort_by {|s| s.priority || Integer::INT32_MAX }
      end
  
      def merge_authorities
        authorities = {}
        sorted_fragments.each do |fragment|
          fragment.authorities.each do |authority|
            authorities["#{authority.authority_id}-#{authority.name}"] ||= authority
          end
        end
        authorities.values
      end
  
      def find_fragment(source_id)
        self.fragments.where(source_id: source_id).first
      end
    end
  end
end
