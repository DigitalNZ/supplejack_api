# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module Utils
  extend self

  def load_yaml(file_name)
    path = File.join(Rails.root, 'config', file_name)
    if File.exist?(path)
      File.open(path) do |file|
        YAML.load(file.read)
      end
    else
      {}
    end
  end

  def call_block(dsl, &block)
    Sunspot::Util.instance_eval_or_call(dsl, &block)
  end

  def safe?(text, version = 3)
    !unsafe?(text, version)
  end

  def unsafe?(text, version = 3)
    if version == 3
      text.to_s.match(/([\w]{3,40}:)/)
    else
      text.to_s.match(/([\w]{3,40}:)|(AND|OR|NOT)/)
    end
  end

  #
  # Return a array no matter what.
  #
  def array(object)
    case object
    when Array
      object
    when String
      object.present? ? [object] : []
    when NilClass
      []
    else
      [object]
    end
  end

  def time(value)
    if value.blank?
      return nil
    elsif value.is_a?(Integer)
      number = value.to_s[0..9]
      Time.at(number.to_i)
    elsif value.is_a?(String) && value.match(/^\d{13}$/)
      number = value[0..9]
      Time.at(number.to_i)
    else
      Time.parse(value) rescue nil
    end
  end

  def capitalize_first_word(string)
    return '' unless string.present?
    first_letter = string.to_s[0].upcase
    string[0] = first_letter
    string
  end
end
