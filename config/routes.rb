Rails.application.routes.draw do
  resources :users do
    collection do
      get :show_login
      post :login
      post :logout
    end
  end
  resources :sessions
  root to: "users#login"
end
