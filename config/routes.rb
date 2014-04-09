SupplejackApi::Engine.routes.draw do
	devise_for :users, class_name: 'SupplejackApi::User'  

  root to: 'records#index'

  get '/status', to: 'records#status', as: 'status'

  # Resources
  resources :records, only: [:index, :show]
  resources :users, only: [:index, :show, :edit, :update]
end
