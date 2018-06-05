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

    %i[index index! remove remove!].each do |method|
      define_method(method) do |*objects|
        @buffer = SupplejackApi::RecordRedisQueue.new
        method = method.to_s.delete('!').to_sym

        objects = objects.flatten.compact
        object_ids = objects.map { |o| o.id.to_s }.compact

        @buffer.send("push_to_#{method}_buffer", object_ids)
      end
    end

    %i[remove_by_id remove_by_id!].each do |method|
      define_method(method) do |clazz, id|
        SupplejackApi::IndexWorker.perform_async(method, class: clazz, id: id.to_s)
      end
    end

    def remove_all(clazz = nil)
      SupplejackApi::IndexWorker.perform_async(:remove_all, clazz.to_s)

      commit
    end

    def remove_all!(clazz = nil)
      SupplejackApi::IndexWorker.perform_async(:remove_all, clazz.to_s)

      commit
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
