module SupplejackApi
  class User
    include Mongoid::Document
    include Mongoid::Timestamps
    include ActiveModel::ForbiddenAttributesProtection

    store_in collection: 'users'

    # Include default devise modules. Others available are:
    # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
    devise :trackable, :token_authenticatable, :database_authenticatable

    # Database authenticatable
    # field :email,              :type => String, :null => false
    # field :encrypted_password, :type => String, :null => false
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
    field :max_requests,      type: Integer,  default: 10000
    field :role,              type: String,   default: -> { Schema.default_role.name }

    field :daily_activity,        type: Hash
    field :daily_activity_stored, type: Boolean, default: true
    index daily_activity_stored: 1

    has_many :user_activities, class_name: 'SupplejackApi::UserActivity'

    scope :with_daily_activity, where(daily_activity_stored: false)

    alias_method :api_key, :authentication_token

    before_save :ensure_authentication_token
  
    def name
      name = self[:name]
      name.present? ? name : username
    end
  
    def updated_today?
      self.updated_at > Time.now.beginning_of_day
    end
  
    def check_daily_requests
      if updated_today?
        increment_daily_requests
      else
        self.daily_requests = 1
      end
  
      if self.daily_requests == (self.max_requests * 0.9).floor
        RequestLimitMailer.at90percent(self).deliver
        RequestLimitMailer.at90percent_admin(self).deliver
      elsif self.daily_requests == self.max_requests
        RequestLimitMailer.at100percent(self).deliver
        RequestLimitMailer.at100percent_admin(self).deliver
      end
    end
  
    def increment_daily_requests
      self.daily_requests ||= 0
      self.daily_requests += 1
    end
    
    def update_tracked_fields(request)
      old_current, new_current = self.current_sign_in_at, Time.now.utc
      self.last_sign_in_at     = old_current || new_current
      self.current_sign_in_at  = new_current
  
      old_current, new_current = self.current_sign_in_ip, request.ip
      self.last_sign_in_ip     = old_current || new_current
      self.current_sign_in_ip  = new_current
  
      self.sign_in_count ||= 0
      self.sign_in_count += 1
    end
  
    def update_daily_activity(request)
      controller = request.params[:controller].to_s
      action = request.params[:action].to_s
  
      if controller == 'records' && action == 'index'
        controller, action = 'search', 'records'
      elsif controller == 'custom_searches' && action == 'records'
        controller, action = 'search', 'custom_search'
      elsif controller == 'set_items'
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
      self.user_activities.gt(created_at: Time.now-30.days).each {|activity| count += activity.total.to_i}
      self.monthly_requests = count
    end
  
    def requests_per_day(days=30)
      user_activities = self.user_activities.gt(created_at: Time.now-days.days).asc(:created_at).to_a

      requests = []
      date = Date.today - days.days
      while date < Date.today
        date = date + 1.days
        requests << (user_activities.find {|ua| ua.created_at.to_date == date}.try(:total) || 0)
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
      if id.to_s.length == 24
        user = self.find(id)
      else
        user = self.find_by_api_key(id)
      end
  
      raise Mongoid::Errors::DocumentNotFound.new(self, id, id) unless user
      user
    end
    
  end
end
