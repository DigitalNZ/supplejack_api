Rails.application.routes.draw do

  mount SupplejackApi::Engine => '/', as: 'supplejack_api'
end
