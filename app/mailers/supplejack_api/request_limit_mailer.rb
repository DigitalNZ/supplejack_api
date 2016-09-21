# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class RequestLimitMailer < ActionMailer::Base
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
