# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class IndexWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'critical', retry: 1

    def perform(sunspot_method, object = nil)
      sunspot_method = sunspot_method.to_sym
      object = object.with_indifferent_access if object.is_a? Hash

      Rails.logger.level = 1 unless Rails.env.development?

      session = Sunspot.session
      Sunspot.session = Sunspot::Rails.build_session
      case sunspot_method
      when :index
        self.index(self.find_all(object[:class], object[:id]))
      when :remove
        self.remove(self.find_all(object[:class], object[:id]))
      when :remove_all
        self.remove_all(object)
      when :commit_if_dirty
        self.commit_if_dirty
      when :commit_if_delete_dirty
        self.commit_if_delete_dirty
      when :commit
        self.commit
      else
        raise "Error: undefined protocol for IndexWorker: #{sunspot_method} (#{objects})"
      end
      Sunspot.session = session
    end

    def index(object)
      Sunspot.index(object)
    end

    def remove(object)
      Sunspot.remove(object)
    end

    def remove_by_id(klass, id)
      Sunspot.remove_by_id(klass, id)
    end

    def remove_all(klass = nil)
      klass = klass.constantize unless klass.nil?
      Sunspot.remove_all(klass)
    end

    def commit
      begin
        # on production, use autocommit in solrconfig.xml
        # or commitWithin whenever sunspot supports it
        sleep(20) unless Rails.env.test? # Sleep 20 seconds to wait for other potential jobs being executed in parallel
        Sunspot.commit
      rescue RSolr::Error::Http => e
        Rails.logger.error e.inspect
      end
    end

    def commit_if_dirty
      Sunspot.commit_if_dirty
    end

    def commit_if_delete_dirty
      Sunspot.commit_if_delete_dirty
    end

    def find_all(klass, ids)
      object_ids = *ids
      klass.constantize.where(:id.in => object_ids)
    end
  end
end
