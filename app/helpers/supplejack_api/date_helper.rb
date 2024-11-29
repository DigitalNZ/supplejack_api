module SupplejackApi
  module DateHelper
    def parse_as_solr_date_range(value)
      return if ::Date.edtf(value).blank?
  
      # return range for range based dates
      return parse_as_range(value) if value.index("/").present?
  
      # return range for year or year-month type dates ( less than 3 parts to the date )
      return parse_as_range("#{value}/#{value}") if ::Date.edtf(value).values.length < 3
  
      # return single date if year, month, day are all provided
      solr_format(::Date.edtf(value))
    end

    module_function :parse_as_solr_date_range
  
    # Solr wants datetimes in Z time "1851-01-01T00:00:00Z" (utc)
    # Ruby DateTime .iso8601 returns the date in local time +00:00 unless .utc is called
    def solr_format(date)
      return date.utc.iso8601 if date.is_a?(::DateTime)
  
      date.iso8601
    end

    module_function :solr_format
  
    def parse_as_range(date_to_parse)
      intervals = ::Date.edtf(date_to_parse)
      return nil if intervals.blank?
  
      "[#{solr_format(intervals.first)} TO #{solr_format(intervals.last)}]"
    end
    module_function :parse_as_range
  end
end