# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

SupplejackApi::Engine.routes.draw do
  root to: 'records#index'

  # Records
  resources :records, only: [:index, :show]

  # Concepts
  resources :concepts, only: [:index, :show]
  
  # Harvester
  namespace :harvester, constraints: SupplejackApi::HarvesterConstraint.new do
    resources :records, only: [:create, :update, :show] do
      # TODO Add record parameter constraint for update and create
      collection do
        post :flush
        put :delete
      end
      resources :fragments, only: [:create]
    end
    resources :fragments, only: [:destroy]
  end

  # Partners
  resources :partners, except: [:destroy], constraints: SupplejackApi::HarvesterConstraint.new do
    resources :sources, except: [:update, :index ,:destroy], shallow: true do
      get :reindex, on: :member
      get :link_check_records, on: :member
    end
  end

  # Sources
  resources :sources, only: [:index, :update], constraints: SupplejackApi::HarvesterConstraint.new
  
  # User level authentication
  resources :users, only: [:show]
  devise_for :users, class_name: 'SupplejackApi::User'

  # Admin level authentication
  namespace :admin do
    devise_for :users, class_name: 'SupplejackApi::User'
    resources :users, only: [:index, :show, :edit, :update]
    resources :site_activities, only: [:index]
  end

  get '/status', to: 'records#status', as: 'status'

  mount ::Resque::Server.new, at: '/resque'
end
