# frozen_string_literal: true
# This was authored by HeyZap (http://www.heyzap.com/) and is available at http://stdout.heyzap.com/2011/08/17/sunspot-resque-session-proxy/

module Sunspot
  class SidekiqSessionProxy < Sunspot::SessionProxy::AbstractSessionProxy
    attr_reader :original_session, :batch_size

    delegate :config, :delete_dirty?, :dirty?,
             :new_search, :search,
             :new_more_like_this, :more_like_this,
             :batch, to: :session

    def initialize(session, batch_size = 1000)
      @original_session = session
      @batch_size = batch_size
    end

    alias session original_session

    [:index, :index!, :remove, :remove!].each do |method|
      define_method(method) do |*objects|
        @buffer = SupplejackApi::IndexBuffer.new
        method = method.to_s.delete('!').to_sym

        start = 0
        objects = objects.flatten.compact
        object_ids = objects.map { |o| o.id.to_s }.compact
        total_ids_to_index = object_ids.size + @buffer.send("#{method}_record_ids_count")

        if total_ids_to_index < 100
          @buffer.send("#{method}_record_ids=", object_ids)
        else
          total_ids = object_ids + @buffer.pop_record_ids(method)
          batch_object_ids = total_ids[start..(batch_size - 1)]
          class_name = objects.first.class.name

          while batch_object_ids do
            index_worker_args = { class: class_name, id: batch_object_ids }

            SupplejackApi::IndexWorker.perform_async(method, index_worker_args) if batch_object_ids.try(:any?)

            start += batch_size
            batch_object_ids = total_ids[start..(start + batch_size - 1)]
          end

          SupplejackApi::IndexWorker.perform_async(:commit)
        end
      end
    end

    [:remove_by_id, :remove_by_id!].each do |method|
      define_method(method) do |clazz, id|
        SupplejackApi::IndexWorker.perform_async(method, class: clazz, id: id.to_s)
      end
    end

    def remove_all(clazz = nil)
      SupplejackApi::IndexWorker.perform_async(:remove_all, clazz.to_s)
    end

    def remove_all!(clazz = nil)
      SupplejackApi::IndexWorker.perform_async(:remove_all, clazz.to_s)
    end

    def commit(_soft_commit = false)
      SupplejackApi::IndexWorker.perform_async(:commit)
    end

    def commit_if_dirty(soft_commit = false)
      # no-op
    end

    def commit_if_delete_dirty(soft_commit = false)
      # no-op
    end
  end
end
