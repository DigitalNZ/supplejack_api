# frozen_string_literal: true

module SupplejackApi
  class RequestLimitMailer < ApplicationMailer
    default from: ENV['REQUEST_LIMIT_MAILER']

    def at90percent(user)
      @limit = user.max_requests

      mail(to: [user.email].join(', '),
           subject: 'Your API key has exceeded 90% of its daily limit')
    end

    def at100percent(user)
      @limit = user.max_requests

      mail(to: [user.email].join(', '),
           subject: 'Your API key exceeded its daily limit')
    end

    def at90percent_admin(user)
      @limit = user.max_requests
      @email = user.email

      mail(to: ENV['REQUEST_LIMIT_MAILER'],
           subject: 'A API key has exceeded 90% of its daily limit')
    end

    def at100percent_admin(user)
      @limit = user.max_requests
      @email = user.email

      mail(to: ENV['REQUEST_LIMIT_MAILER'],
           subject: 'A API key exceeded its daily limit')
    end
  end
end
