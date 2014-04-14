module Sunspot
  module Query
    class Spellcheck < Connective::Conjunction
      attr_accessor :options

      def initialize(options = {})
        @options = options
      end

      def to_params
        options = {}
        @options.each do |key, val|
          options["spellcheck." + Sunspot::Util.method_case(key)] = val
        end
        { :spellcheck => true }.merge(options)
      end
    end
  end
end

module Sunspot
  module Query
    class CommonQuery
      def spellcheck options = {}
        @components << Spellcheck.new(options)
      end
    end
  end
end

module Sunspot
  module Search
    class AbstractSearch
      attr_accessor :solr_result

      def raw_suggestions
        ["spellcheck", "suggestions"].inject(@solr_result){|h,k| h && h[k]}
      end

      def suggestions
        suggestions = ["spellcheck", "suggestions"].inject(@solr_result){|h,k| h && h[k]}
        return nil unless suggestions.is_a?(Array)

        suggestions_hash = {}
        index = -1
        suggestions.each do |sug|
          index += 1
          next unless sug.is_a?(String)
          break unless suggestions.count > index + 1
          suggestions_hash[sug] = suggestions[index+1].try(:[], "suggestion") || suggestions[index+1]
        end
        suggestions_hash
      end

      def all_suggestions
        suggestions.inject([]){|all, current| all += current}
      end

      def collation
        suggestions.try(:[], "collation")
      end
    end
  end
end

module Sunspot
  module DSL
    class StandardQuery
      def spellcheck options = {}
        @query.spellcheck(options)
      end
    end
  end
end

module Sunspot
  module Util
    class<<self
      def method_case(string_or_symbol)
        string = string_or_symbol.to_s
        first = true
        string.split('_').map! { |word| word = first ? word : word.capitalize; first = false; word }.join
      end
    end
  end
end