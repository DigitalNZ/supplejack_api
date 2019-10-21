# frozen_string_literal: true

module SupplejackApi
  class StoreUserActivityWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'critical', retry: 3

    # rubocop:disable Metrics/LineLength
    def perform
      Rails.logger.info '[StoreUserActivityWorker] Starting Execution'

      all_users = User.all.no_timeout
      Rails.logger.error '[StoreUserActivityWorker] No users were returned from mongo' if all_users.empty?

      all_users.each do |user|
        if user.daily_activity_stored
          Rails.logger.warn "[StoreUserActivityWorker] Skipping Reset - Daily activity already stored for #{user.inspect}"
          next
        end
        user.user_activities << UserActivity.build_from_user(user.daily_activity)
        user.calculate_last_30_days_requests
        user.reset_daily_activity
        user.save!
      rescue StandardError => e
        Rails.logger.error "[StoreUserActivityWorker] Failed resetting activity for #{user.inspect} with #{e}"
        raise
      end

      Rails.logger.info '[StoreUserActivityWorker] Generating SiteActivity'
      SiteActivity.generate_activity
      Rails.logger.info '[StoreUserActivityWorker] Completed SiteActivity'
    rescue StandardError => e
      Rails.logger.error "[StoreUserActivityWorker] Exception (#{e.inspect})"
      raise
    end
    # rubocop:enable Metrics/LineLength
  end
end
