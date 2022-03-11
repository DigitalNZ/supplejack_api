# frozen_string_literal: true

require 'activeresource'

module SupplejackApi
  class AbstractJob < ActiveResource::Base
    self.site = ENV['WORKER_HOST']
    headers['Authorization'] = "Token token=#{ENV['WORKER_KEY']}"

    class << self
      def active_job_source_ids
        jobs = find(:all, params: { status: 'active' })

        jobs.map(&:source_id).compact
      end
    end
  end
end
