require 'sidekiq/web'

SupplejackApi::Engine.routes.draw do
  root to: 'records#index', defaults: {format: 'json'}

  scope '(/:version)', version: /v3/, defaults: { version: nil, format: 'json' } do
    # User level authentication
    resources :users, only: [:show, :create, :update, :destroy]


    # Concepts
    resources :concepts, only: [:index, :show] do
      resources :records, only: [:index], on: :member
    end

    # Records
    resources :records, only: [:index, :show], defaults: {format: 'json'} do
      get :multiple, on: :collection
      get :more_like_this

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
        post :create_batch
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
