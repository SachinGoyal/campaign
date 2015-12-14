Rails.application.routes.draw do

  post 'uploads/create'

  post 'newsletter_emails/unsubscribe'
  get 'newsletter_emails/unsubscribe'

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

  resources :profiles, concerns: [:edit_all, :search]
  resources :contact_imports

  get 'home/index'

  devise_for :users, :path_prefix => 'auth'

  devise_scope :user do
    get '/signout', to: 'devise/sessions#destroy', as: :signout
  end
  resources :users,concerns: [:edit_all,:search]
  root to: "home#index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
