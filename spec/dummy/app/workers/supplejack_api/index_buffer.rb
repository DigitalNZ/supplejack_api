# frozen_string_literal: true
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

    def pop_record_ids(method = :index, batch_size = 1000)
      Rails.logger.info "INDEX ISSUE SUPPLEJACK PI"
      future_ids = OpenStruct.new(value: [])
      number_of_ids = count_for_buffer_type(method)

      Rails.logger.info "INDEX ISSUE: number_of_ids #{number_of_ids}"

      Sidekiq.redis do |conn|
        conn.pipelined do
          buffer = buffer_name(method)
          range_end = (number_of_ids < batch_size) ? number_of_ids : batch_size
          ids = conn.lrange(buffer, 0, range_end)

          Rails.logger.info "INDEX ISSUE: ids #{ids}"

          # keeping everything from range_end to count +1000
          # +1000 because if harvesting is running there caould be more id in
          # the queue when it gets to this statement.
          conn.ltrim(buffer, range_end + 1, number_of_ids + 1000)
          Rails.logger.info "INDEX ISSUE: ids_left #{ids = conn.lrange(buffer, 0, range_end)}"
        end
      end

      # Record ids get double pushed to Redis during creation
      # I'm guessing because they are created and then something
      # is updated. The uniq takes care of that
      ids.value.uniq || []
    end

    def records_to_index
      @records_to_index ||= ::Record.where(:id.in => self.pop_record_ids(:index)).to_a
      @records_to_index.keep_if {|r| r.should_index? }
      @records_to_index
    end

    def records_to_remove
      @records_to_remove ||= ::Record.where(:id.in => self.pop_record_ids(:remove)).to_a
      @records_to_remove.delete_if {|r| r.should_index?}
      @records_to_remove
    end

    [:index, :remove].each do |method|
      define_method("push_to_#{method}_buffer") do |ids|
        Sidekiq.redis do |conn|
          conn.pipelined do
            ids.each do |id|
              Rails.logger.info("METHOD: #{method}")
              conn.rpush(buffer_name(method), id)
            end
          end
        end
      end

      define_method("#{method}_buffer_count") do
        count_for_buffer_type(method)
      end
    end

    private

    def count_for_buffer_type(type)
      Sidekiq.redis do |conn|
        conn.llen(buffer_name(type))
      end
    end

    def buffer_name(type)
      "#{type}_buffer_record_ids"
    end
  end
end
