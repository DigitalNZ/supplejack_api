# frozen_string_literal: true

module Utils
  module_function

  def load_yaml(file_name)
    path = Rails.root.join('config', file_name)
    if File.exist?(path)
      File.open(path) do |file|
        YAML.safe_load(file.read)
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
      nil
    elsif value.is_a?(Integer)
      number = value.to_s[0..9]
      Time.zone.at(number.to_i).utc
    elsif value.is_a?(String) && value.match(/^\d{13}$/)
      number = value[0..9]
      Time.zone.at(number.to_i).utc
    else
      Time.parse(value).utc rescue nil
    end
  end

  # Make only the first letter of the string capital
  # .capilatize makes the rest of the string lower case
  # And hence this method.
  #
  # @author Ben
  # @last_modified Eddie
  # @param string [String] the string
  # @return [String] the string with capital first letter
  def capitalize_first_word(string)
    return '' if string.blank?

    string_dup = string.dup
    string_dup[0] = string_dup.to_s[0].upcase
    string_dup
  end
end
