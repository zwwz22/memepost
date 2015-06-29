require 'sidekiq/web'
Memepost::Application.routes.draw do
  get "users/index"

  get "users/show"

  mount WeixinRailsMiddleware::Engine, at: "/"

  devise_for :admins, :controllers => { :sessions => "admin/sessions" }

  root :to => redirect('http://memeing.cn')

  namespace :admin  do
    root :to => 'dashboard#index'

    # sidekiq admin view
    authenticate :admin do
      mount Sidekiq::Web => '/sidekiq'
    end

    resources :admins
    resources :templates
    resources :categories
    resources :questions
    resources :users
  end

  namespace :wap do
    root :to => 'designs#index'
    resources :designs do
      collection do
        post :upload
        get  :write_address
        get  :write_blessings
        get :success
        post :create_order
        post :get_templates
        post :update_address
        post :update_blessings
      end

    end
  end
end
