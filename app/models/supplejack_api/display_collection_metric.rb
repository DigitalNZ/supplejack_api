# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class DisplayCollectionMetric
    include Mongoid::Document
    include Mongoid::Timestamps

    before_save :replace_periods
    after_save :replace_unicode_periods
    after_find :replace_unicode_periods

    store_in collection: 'daily_metrics'

    embedded_in :daily_item_metric, class_name: 'SupplejackApi::DailyItemMetric'

    field :name,                 type: String
    field :total_active_records, type: Integer
    field :total_new_records,    type: Integer
    field :category_counts,      type: Hash
    field :copyright_counts,     type: Hash

    # MongoDB does not allow you to store hashes that have keys with peroids in the name
    # Some of the copyrights contain version numbers which prevents them from being stored 
    # as keys directly. This replaces periods with the unicode equivalent
    def replace_periods
      self.category_counts  = Hash[self.category_counts. map(&key_replacer(".", "\u2024"))] if self.category_counts
      self.copyright_counts = Hash[self.copyright_counts.map(&key_replacer(".", "\u2024"))] if self.copyright_counts
    end

    # MongoDB does not allow you to store hashes that have keys with peroids in the name
    # Some of the copyrights contain version numbers which prevents them from being stored 
    # as keys directly. This replaces unicode periods with normal periods so this quirk 
    # doesn't affect the application code
    def replace_unicode_periods
      self.category_counts  = Hash[self.category_counts. map(&key_replacer("\u2024", "."))] if self.category_counts
      self.copyright_counts = Hash[self.copyright_counts.map(&key_replacer("\u2024", "."))] if self.copyright_counts
    end

    private

    def key_replacer(target, replacement)
      lambda do |kv|
        key, value = kv

        [key.gsub(target, replacement), value]
      end
    end
  end
end
