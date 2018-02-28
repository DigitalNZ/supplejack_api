

module SupplejackApi
  class StoreUserActivityWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'default'

    def perform
      SupplejackApi::User.all.each do |user|
        user.user_activities << SupplejackApi::UserActivity.build_from_user(user.daily_activity) unless user.daily_activity_stored
        user.calculate_last_30_days_requests
        user.reset_daily_activity
        user.save
      end

      SupplejackApi::SiteActivity.generate_activity
    end
  end
end
