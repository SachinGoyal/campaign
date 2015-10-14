Rails.application.routes.draw do

  get 'contact_imports/new'


  concern :edit_all do
    collection do 
      get :edit_all
    end
  end

  resources :companies ,concerns: :edit_all do
    member do
      get :select_roles
    end
    collection do
      get :search
    end
  end
  resources :functions
  resources :settings
  resources :templates
  resources :contacts ,concerns: :edit_all do
    collection do
     post :import 
     get :search
    end
  end
  resources :campaigns ,concerns: :edit_all
  resources :attributes ,concerns: :edit_all

  resources :roles
  resources :newsletters ,concerns: :edit_all
  resources :profiles ,concerns: :edit_all
  resources :contact_imports

  get 'home/index'

  devise_for :users, :path_prefix => 'auth'
  resources :users,concerns: :edit_all do
    collection { post :search, to: 'users#search'
                get :search, to: 'users#search' }
  end
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
