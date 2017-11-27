# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module ApplicationHelper
    def flash_messages
      return nil if flash.empty?

      flash.map do |type, message|
        type = :success if type.to_s == 'notice'
        content_tag(:div, message, class: "alert-box #{type} margin-top")
      end.join.html_safe
    end

    def sortable(klass, column)
      path = "admin_#{klass.to_s.tableize}_path"
      sort_column, sort_direction = extract_sort_info
      direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
      css_class = column == sort_column ? "current #{sort_direction}" : nil

      label = safe_join([t("#{klass.to_s.tableize}.#{column}", default: column.titleize), content_tag(:span)])
      link_to label, send(path, order: "#{column}_#{direction}"), class: css_class
    end

    def extract_sort_info
      return unless params[:order].to_s =~ /^([\w\_\.]+)_(desc|asc)$/

      @sort_column = Regexp.last_match(1)
      @sort_direction = Regexp.last_match(2)

      [@sort_column, @sort_direction]
    end
  end
end
