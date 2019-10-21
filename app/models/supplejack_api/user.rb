# frozen_string_literal: true

# TODO: Remove custom_search stuff to slim the class?
# rubocop:disable Metrics/ClassLength
module SupplejackApi
  class User
    include Mongoid::Document
    include Mongoid::Timestamps
    include ActiveModel::ForbiddenAttributesProtection
    include Sortable::Query

    store_in collection: 'users'

    # Include default devise modules. Others available are:
    # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
    devise :trackable, :database_authenticatable, :token_authenticatable

    # Database authenticatable
    # field :email,              type: String, null: false
    # field :encrypted_password, type: String, null: false
    field :email,               type: String
    field :encrypted_password,  type: String
    field :name,                type: String
    field :username,            type: String

    index authentication_token: 1

    # Trackable
    field :sign_in_count,      type: Integer
    field :current_sign_in_at, type: Time
    field :last_sign_in_at,    type: Time
    field :current_sign_in_ip, type: String
    field :last_sign_in_ip,    type: String

    # Token authenticatable
    field :authentication_token, type: String

    field :daily_requests,    type: Integer,  default: 0
    field :monthly_requests,  type: Integer,  default: 0
    field :max_requests,      type: Integer,  default: 10_000
    field :role,              type: String,   default: 'developer'

    field :daily_activity,        type: Hash
    field :daily_activity_stored, type: Boolean, default: true
    index daily_activity_stored: 1

    has_many :user_activities, class_name: 'SupplejackApi::UserActivity', dependent: :destroy

    scope :with_daily_activity, -> { where(daily_activity_stored: false) }

    alias api_key authentication_token

    validates :authentication_token, uniqueness: true

    before_save :ensure_authentication_token

    has_many :user_sets, dependent: :destroy, autosave: true, class_name: 'SupplejackApi::UserSet' do
      def custom_find(id)
        user_set = if BSON::ObjectId.legal?(id.to_s)
                     find(id) rescue nil
                   else
                     where(url: id).first
                   end
      end
    end

    def sets=(attrs_array)
      if attrs_array.try(:any?)
        attrs_array.each { |attrs| user_sets.build(attrs) }
      else
        false
      end
    end

    def name
      name = self[:name]
      name.presence || username
    end

    def updated_today?
      updated_at > Time.zone.now.beginning_of_day
    end

    def check_daily_requests
      if updated_today?
        increment_daily_requests
      else
        self.daily_requests = 1
      end

      if daily_requests == (max_requests * 0.9).floor
        SupplejackApi::RequestLimitMailer.at90percent(self).deliver_now
        SupplejackApi::RequestLimitMailer.at90percent_admin(self).deliver_now
      elsif daily_requests == max_requests
        SupplejackApi::RequestLimitMailer.at100percent(self).deliver_now
        SupplejackApi::RequestLimitMailer.at100percent_admin(self).deliver_now
      end
    end

    def increment_daily_requests
      self.daily_requests ||= 0
      self.daily_requests += 1
    end

    def update_tracked_fields(request)
      old_current = current_sign_in_at
      new_current = Time.now.utc
      self.last_sign_in_at     = old_current || new_current
      self.current_sign_in_at  = new_current

      old_current = current_sign_in_ip
      new_current = request.ip
      self.last_sign_in_ip     = old_current || new_current
      self.current_sign_in_ip  = new_current

      self.sign_in_count ||= 0
      self.sign_in_count += 1
    end

    def update_daily_activity(request)
      # Get the controller name and strips out the `supplejack_api/` namespace
      controller = request.params[:controller].to_s.gsub('supplejack_api/', '')
      action = request.params[:action].to_s

      if controller == 'records' && action == 'index'
        controller = 'search'
        action = 'records'
      elsif %w[set_items story_items].include? controller
        controller = 'user_sets'
        action = "#{action}_item"
      end

      self.daily_activity ||= {}
      self.daily_activity[controller] ||= {}

      current_value = self.daily_activity[controller][action].to_i
      self.daily_activity[controller][action] = current_value + 1

      self.daily_activity_stored = false
    end

    def reset_daily_activity
      self.daily_requests = 0
      self.daily_activity = nil
      self.daily_activity_stored = true
    end

    def over_limit?
      updated_today? && daily_requests > max_requests
    end

    def calculate_last_30_days_requests
      count = 0
      user_activities.gt(created_at: Time.zone.now - 30.days).each { |activity| count += activity.total.to_i }
      self.monthly_requests = count
    end

    def requests_per_day(days = 30)
      today = Time.zone.now.to_date
      user_activities = self.user_activities.gt(created_at: today - days.days).asc(:created_at).to_a

      requests = []
      date = today - days.days
      while date < today
        date += 1.day
        requests << (user_activities.find { |ua| ua.created_at.to_date == date }.try(:total) || 0)
      end
      requests
    end

    def name_or_user
      name.present? ? split_on_at_symbol(name) : split_on_at_symbol(username)
    end

    def split_on_at_symbol(value)
      if value.present? && value.include?('@')
        value.split('@').first
      else
        value
      end
    end

    def self.find_by_api_key(api_key)
      where(authentication_token: api_key).first
    end

    def self.custom_find(id)
      user = if id.to_s.length == 24
               find(id)
             else
               find_by_api_key(id)
             end

      raise Mongoid::Errors::DocumentNotFound.new(self, id, id) unless user

      user
    end

    def admin?
      RecordSchema.roles[role.to_sym].try(:admin)
    end

    def can_change_featured_sets?
      admin?
    end
  end
end
