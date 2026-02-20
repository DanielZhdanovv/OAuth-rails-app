Rails.application.routes.draw do
  devise_for :users, class_name: "Oauth::User"
  namespace :server do
    get "oauth/authorize", to: "oauth#authorize"
    get "oauth/redirect_to_client", to: "oauth#redirect_to_client"
  end

  namespace :client do
    root "pages#index"
    get "session/login", to: "sessions#login"
    get "session/logout", to: "sessions#logout"
    get "session/user_registration", to: "sessions#user_registration"
    get "session/callback", to: "sessions#callback"
  end
end
