require 'resque/server'

Rails.application.routes.draw do

  root 'people#index'

  resources :people, constraints: {id: /[A-Za-z0-9\._-]+/}, only: [:show, :photo] do
    get :photo
  end
  resource :sessions, only: [:new, :create, :destroy]
  resource :profile, only: [:edit, :update_passowrd] do
    patch :update_passowrd
    patch :update_photo
  end

  namespace :api do
    namespace :external do
      resources :people_photo, only: [:show], constraints: {id: /[A-Za-z0-9\._-]+/}
    end
  end

  namespace :admin do
    constraints CanAccessResque do
      mount Resque::Server, at: 'resque'
    end

    get '', to: redirect('/admin/people'), as: :index
    resources :people, constraints: {id: /[A-Za-z0-9\._-]+/} do
      resource :people_photo, constraints: {person_id: /[A-Za-z0-9\._-]+/}, only: [:update] do
      end
    end

    resources :groups, constraints: {id: /[A-Za-z0-9\._-]+/} do
      resource :groups_members, constraints: {group_id: /[A-Za-z0-9\._-]+/}, only: [:create, :destroy] do
      end
    end
  end
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
