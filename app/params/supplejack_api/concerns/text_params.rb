# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module TextParams
      attr_reader :text

      private

      # Downcase all queries before sending to SOLR, except queries
      # which have specific lucene syntax.
      def init_text(text: '', **_)
        @text = text

        @text = text.downcase.gsub(/ and | or | not /, &:upcase) unless text.match(/:"/)
      end
    end
  end
end
