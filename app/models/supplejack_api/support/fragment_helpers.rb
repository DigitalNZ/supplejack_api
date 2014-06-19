# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Support
    module FragmentHelpers
      extend ActiveSupport::Concern

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
          self.merged_fragment = fragment_class.new

          fragment_class.mutable_fields.each do |name, field_type|
            if field_type == Array
              values = Set.new
              sorted_fragments.each do |s|
                values += Array(s.public_send(name))
              end
              self.merged_fragment.public_send("#{name}=", values.to_a)
            else
              values = sorted_fragments.to_a.map {|s| s.public_send(name) }
              self.merged_fragment.public_send("#{name}=", values.compact.first)
            end
          end
        end
      end

      # Fetch the attribute from the underlying
      # merged_fragment or only fragment.
      # Means that record.{attribute} (ie. record.name) works for convenience
      # and abstracts away the fact that fragments exist
      def method_missing(symbol, *args, &block)

        # TODO CHECK IF WE STILL WANT THIS
        # if symbol.to_s.include?(':')
        #   symbol = symbol.to_s.gsub(':', '_').to_sym
        # end

        type = fragment_class.mutable_fields[symbol.to_s]
        if self.merged_fragment
          value = self.merged_fragment.public_send(symbol)
        elsif self.fragments.first
          value = self.fragments.first.public_send(symbol)
        end
        (type == Array) ? Array(value) : value
      end

      def sorted_fragments
        self.fragments.sort_by {|s| s.priority || Integer::INT32_MAX }
      end

      def find_fragment(source_id)
        self.fragments.where(source_id: source_id).first
      end
    end
  end
end
