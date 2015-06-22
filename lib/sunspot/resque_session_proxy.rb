# This was authored by HeyZap (http://www.heyzap.com/) and is available at http://stdout.heyzap.com/2011/08/17/sunspot-resque-session-proxy/

module Sunspot
  class ResqueSessionProxy < Sunspot::SessionProxy::AbstractSessionProxy

    attr_reader :original_session, :batch_size

    delegate :config, :delete_dirty?, :dirty?,
    :new_search, :search,
    :new_more_like_this, :more_like_this,
    :batch, :to => :session

    def initialize(session, batch_size=1000)
      @original_session = session
      @batch_size = batch_size
    end

    alias_method :session, :original_session

    [:index, :index!, :remove, :remove!].each do |method|
      define_method(method) do |*objects|
        @buffer = SupplejackApi::IndexBuffer.new
        method = method.to_s.gsub("!", "").to_sym

        start = 0
        objects = objects.flatten.compact
        object_ids = objects.map {|o| o.id.to_s }.compact
        total_ids = object_ids + @buffer.pop_record_ids(method)

        if total_ids.size < 100
          @buffer.send("#{method}_record_ids=", total_ids)
        else
          batch_object_ids = total_ids[start..(batch_size-1)]
          class_name = objects.first.class.name

          while batch_object_ids do
            Resque.enqueue(SupplejackApi::IndexWorker, method, {:class => class_name, :id => batch_object_ids }) if batch_object_ids.try(:any?)
            start += batch_size
            batch_object_ids = total_ids[start..(start+batch_size-1)]
          end
        end
      end
    end

    [:remove_by_id, :remove_by_id!].each do |method|
      define_method(method) do |clazz, id|
        Resque.enqueue(SupplejackApi::IndexWorker, method, {:class => clazz, :id => id.to_s})
      end
    end

    def remove_all(clazz = nil)
      Resque.enqueue SupplejackApi::IndexWorker, :remove_all, clazz.to_s
    end

    def remove_all!(clazz = nil)
      Resque.enqueue SupplejackApi::IndexWorker, :remove_all, clazz.to_s
    end

    def commit
      Resque.enqueue(SupplejackApi::IndexWorker, :commit)
    end

    def commit_if_dirty(soft_commit = false)
      # no-op
    end

    def commit_if_delete_dirty(soft_commit = false)
      # no-op
    end
  end
end
