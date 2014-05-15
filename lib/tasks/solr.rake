# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'progressbar'

namespace :solr do

  # Index all records with status 'active'
  #
  desc 'Reindex records by specifying a start and end record_ids'
  task :index, [:start_id, :end_id, :batch_size] => [:environment] do |t, args|
    Rails.logger.level = 1
    options = args.to_hash.reverse_merge(start_id: 0, end_id: 0, batch_size: 100000)
    start_id = args[:start_id].to_i
    end_id = args[:end_id].to_i
    batch_size = options[:batch_size].to_i > 0 ? options[:batch_size].to_i : 1000

    total = SupplejackApi::Record.count
    group_count = 0
    start_time = Time.now

    chunks = (start_id..end_id).step(batch_size)
    chunk_count = chunks.count - 1

    puts "[#{start_time}] Starting indexing record_ids: #{start_id} - #{end_id}"

    pbar = ProgressBar.new("Indexing", chunk_count)

    initial_batch_time = Time.now

    total_records = 0

    chunk_count.times do |chunk_index|
      chunk_start = 0
      chunk_end = 0
      c_ms = Benchmark.ms do
        chunk_start = chunks[chunk_index]
        chunk_end = chunks[chunk_index+1]
      end

      record_count = 0
      records = nil
      q_ms = Benchmark.ms do
        records = SupplejackApi::Record.active.where(:record_id.gt => chunk_start, :record_id.lte => chunk_end)
      end

      s_ms = Benchmark.ms do
        records.each_slice(1000) do |record_group|
          record_count += record_group.count
          begin
            Sunspot.index(record_group)
          rescue Timeout::Error => e
            puts "Recovering after Solr timeout. \nException: #{e.inspect}"
            # When connecting to Solr fails, retry it after 60 seconds.
            sleep(60)
            Sunspot.index(record_group)
          end
        end
      end

      pbar.inc
      chunk_time = Time.now - initial_batch_time
      initial_batch_time = Time.now

      total_records += record_count

      puts "Chunk #{chunk_start} - #{chunk_end}, time: #{chunk_time}, records: #{record_count}, q_ms: #{q_ms}, s_ms: #{s_ms}, c_ms: #{c_ms}"
    end

    Sunspot.commit

    elapsed_time = Time.now-start_time
    puts "[#{Time.now}] Completed Indexing. Rows indexed #{total_records}. Rows/sec: #{total_records.to_f/elapsed_time.to_f} (Elapsed: #{elapsed_time} sec.)"
    pbar.finish
  end

  # Delete all records with status 'deleted', 'suppressed' and 'solr_rejected'
  #
  desc 'Delete all records from Solr not in a active status'
  task :delete_inactive, [:start, :minutes, :batch_size] => [:environment] do |t, args|
    Rails.logger.level = 1
    options = args.to_hash.reverse_merge(start: 0, minutes: nil, batch_size: 1000)
    batch_size = options[:batch_size].to_i
    start = options[:start].to_i
    min = options[:minutes].to_i > 0 ? options[:minutes].to_i : nil
    time = Time.now - min.minutes if min

    records_scope = Record.any_in(status: ["deleted", "suppressed", "solr_rejected", "partial"])
    records_scope = records_scope.where(:updated_at.gt => time) if time
    records_count = records_scope.count
    total = records_count - start

    start_time = Time.now
    number_of_batches = total/batch_size
    puts "[#{start_time}] Starting removing from index #{total} records. Number of batches: #{number_of_batches}"

    pbar = ProgressBar.new("Removing from index", number_of_batches)

    initial_batch_time = Time.now

    while start < total do
      records = Record.any_in(status: ["deleted", "suppressed", "solr_rejected", "partial"]).limit(batch_size).skip(start)
      records = records.where(:updated_at.gt => time) if time

      begin
        Sunspot.remove(records)
      rescue Timeout::Error => e
        puts "Recovering after Solr timeout. \nException: #{e.inspect}"
        # When connecting to Solr fails, retry it after 60 seconds.
        sleep(60)
        Sunspot.remove(records)
      end

      pbar.inc
      start += batch_size

      if start % 10000 == 0
        batch_time = Time.now - initial_batch_time
        initial_batch_time = Time.now
        puts "Last 10,000 records took: [#{batch_time}] Next batch: #{start}"
      end
    end

    Sunspot.commit

    elapsed_time = Time.now-start_time
    puts "[#{Time.now}] Completed removing from index. Rows deleted #{total}. Rows/sec: #{total.to_f/elapsed_time.to_f} (Elapsed: #{elapsed_time} sec.)"
    pbar.finish
  end
end