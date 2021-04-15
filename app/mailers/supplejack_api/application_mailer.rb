# frozen_string_literal: true

module SupplejackApi
  class ApplicationMailer < ActionMailer::Base
    default from: ENV['REQUEST_LIMIT_MAILER']
  end
end
