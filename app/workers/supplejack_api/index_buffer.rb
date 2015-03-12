# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

# Handles the logic for storing and retreiving record_ids from Redis
# which should be indexed or removed from Solr.

module SupplejackApi
  class IndexBuffer

    def initialize
      @redis = Resque.redis
    end

    def pop_record_ids(method=:index, num=1000)
      # get all the entries from the list. Need to check what happens if the list doesn't exist
      num ||= 100000
      ids = []
      while ids.count < num and id = @redis.lpop("#{method}_buffer_record_ids")
        ids << id
      end
      ids
    end

    def records_to_index
      @records_to_index ||= SupplejackApi::Record.where(:id.in => self.pop_record_ids(:index)).to_a
      @records_to_index.keep_if {|r| r.should_index? }
      @records_to_index
    end

    def records_to_remove
      @records_to_remove ||= SupplejackApi::Record.where(:id.in => self.pop_record_ids(:remove)).to_a
      @records_to_remove.delete_if {|r| r.should_index?}
      @records_to_remove
    end

    [:index, :remove].each do |method|
      define_method("#{method}_record_ids=") do |ids|
        ids.each do |id|
          # push each id
          @redis.rpush("#{method}_buffer_record_ids", id) 
        end
      end
    end
  end
end
