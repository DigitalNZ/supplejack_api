require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

SupplejackApi::Engine.routes.draw do
  root to: 'records#index'

  namespace :stories do
    resources :moderations, only: [:index]
  end

  scope '(/:version)', version: /v3/, defaults: { version: nil, format: 'json' } do
    # User level authentication
    resources :users, only: [:show, :create, :update, :destroy] do
      get "/sets" => "user_sets#admin_index", as: :user_sets
      get "/stories" => "stories#admin_index", as: :stories
    end

    # Concepts
    resources :concepts, only: [:index, :show] do
      resources :records, only: [:index], on: :member
    end

    # Records
    resources :records, only: [:index, :show] do
      get :multiple, on: :collection
      get :more_like_this
    end

    # Sets
    get '/sets/public' => 'user_sets#public_index', as: :public_user_sets
    get '/sets/featured' => 'user_sets#featured_sets_index', as: :featured_sets

    resources :user_sets, path: 'sets', except: [:new, :edit] do
      resources :set_items, path: 'records', only: [:create, :destroy]
    end

    # Stories
    namespace 'stories' do
      resources :featured, only: [:index]
    end

    resources :stories, except: [:new, :edit] do
      post :reposition_items

      resources :items, controller: :story_items, except: [:new, :edit] do
      end
    end
  end

  scope '/:version/metrics', version: /v3/, defaults: {format: 'json'} do
    get '/', to: 'metrics_api#root'
    get '/facets', to: 'metrics_api#facets'
    get '/global', to: 'metrics_api#global'
  end

  # Harvester
  namespace :harvester do
    resources :records, only: [:create, :update, :show, :index] do
      # TODO: Add record parameter constraint for update and create
      collection do
        post :flush
        put :delete
      end
      resources :fragments, only: [:create]
    end

    get 'preview_records', to: 'preview_records#index'

    resources :concepts, only: [:create, :update]
    resources :fragments, only: [:destroy]
    resources :users, only: [:index, :show, :update]
    resources :activities, only: [:index]

    # Partners
    resources :partners, except: [:destroy] do
      resources :sources, except: [:update, :index, :destroy], shallow: true do
        get :reindex, on: :member
        get :link_check_records, on: :member
      end
    end

    # Sources
    resources :sources, only: [:index, :update]
  end

  get '/status', to: 'status#show'

  get '/schema', to: 'schema#show', :defaults => { format: 'json' }
end
