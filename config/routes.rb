# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

SupplejackApi::Engine.routes.draw do
  root to: 'records#index'

  resources :records, only: [:index, :show]
  

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

  resources :partners, except: [:destroy], constraints: SupplejackApi::HarvesterConstraint.new do
    resources :sources, except: [:update, :index ,:destroy], shallow: true do
      get :reindex, on: :member
      get :link_check_records, on: :member
    end
  end
  resources :sources, only: [:index, :update], constraints: SupplejackApi::HarvesterConstraint.new
  

  resources :users, only: [:show]
  devise_for :users, class_name: 'SupplejackApi::User'


  get '/status', to: 'records#status', as: 'status'


  mount ::Resque::Server.new, at: '/resque'
end
