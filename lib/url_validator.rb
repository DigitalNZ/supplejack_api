# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    valid = false

    return nil if value.blank?

    if value.is_a?(Array)
      value.each do |v|
        valid = validate_url(v)
        break unless valid
      end
    else
      valid = validate_url(value)
    end

    unless valid
      record.errors[attribute] << (options[:message] || 'is not an url')
    end
  end

  def validate_url(value)
    protocol = '(http|https)'
    host = '[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?'
    ip_host = '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
    port = '(:\d{1,5})?'

    regex = %r{ ^#{protocol}:\/\/((#{host})|(#{ip_host}))#{port}\/.*)?$ }ix
    !!value.match(regex)
  end
end
