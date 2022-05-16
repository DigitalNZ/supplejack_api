# frozen_string_literal: true

module Query
  class Base
    attr_reader :options

    def initialize(options)
      @options = options
    end

    # The records that match the criteria within each role will be removed
    # from the search results
    #
    def role_collection_restrictions(role)
      options.schema_class.roles[role.to_sym]&.record_restrictions
    end

    def results
      query.execute.results
    end

    private

    def query
      raise NotImplementedError, 'implement this in children classesr'
    end
  end
end
