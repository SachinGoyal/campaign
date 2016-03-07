Rails.application.routes.draw do

  post 'uploads/create'

  # post 'newsletter_emails/unsubscribe'
  # get 'newsletter_emails/unsubscribe'

  get 'contact_imports/new'
  get 'apis/index'


  concern :edit_all do
    collection do 
      get :edit_all
    end
  end

  concern :search do
    collection do 
      post :search
      get :search
    end
  end   

  resources :newsletter_emails do
   collection do
    post :unsubscribe
    get :unsubscribe
   end
  end

  resources :companies ,concerns: [:edit_all,:search] do
    collection do
      get :select_roles
    end
  end
  resources :functions

  resources :templates ,concerns: [:edit_all,:search] do 
    collection do 
      get :copy
    end
    member do 
      get :preview 
    end
  end
  
  resources :settings ,only: [:edit , :update , :show]


  resources :contacts ,concerns: [:edit_all,:search] do
    collection do
      post :import 
      post :dynamic_field
      post :sample_fields
    end
  end
  resources :campaigns, concerns: [:edit_all,:search] do
    collection do
      get :select_newsletter
      get :reports
      get :stats
    end
  end
  resources :attributes, concerns: :edit_all

  resources :roles, concerns: :edit_all
  resources :newsletters, concerns: [:edit_all, :search] do
    member do
      post :send_now
    end
  end

  resources :profiles, concerns: [:edit_all, :search] do
    member do
      get :extra_fields
    end
  end

  resources :contact_imports

  get 'home/index'

  devise_for :users, :path_prefix => 'auth'

  devise_scope :user do
    get '/signout', to: 'devise/sessions#destroy', as: :signout
  end

  resources :users, concerns: [:edit_all, :search]
  root to: "home#index"

end
