# frozen_string_literal: true

module Stylesheets
  def self.all
    {
      '1' => 'custom_red.css',
      '2' => 'custom_blue.css',
      '3' => 'custom_green.css',
      '4' => 'custom_brown.css',
      '5' => 'widget_red.css',
      '6' => 'widget_blue.css',
      '9' => 'widget_coming_home.css',
      '10' => 'custom_coming_home.css',
      '11' => 'custom_purple.css',
      '12' => 'custom_grey.css',
      '13' => 'widget_purple.css',
      '14' => 'widget_grey.css',
      '15' => 'widget_yellow.css',
      '16' => 'widget_transparent.css'
    }
  end

  def self.base_path
    [ENV['HTTP_HOST'], 'assets/stylesheets/widgets'].join('/')
  end

  def self.url(id)
    [Stylesheets.base_path, Stylesheets.all[id.to_s]].join('/')
  end
end
