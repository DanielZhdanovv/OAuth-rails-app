Rails.application.routes.draw do
  namespace :server do
    devise_for :users, class_name: "Server::User"
    get "oauth/authorize", to: "oauth#authorize"
    get "oauth/after_login", to: "oauth#after_login"
    post "oauth/token", to: "oauth#token"
  end

  namespace :client do
    root "pages#index"
    get "session/login", to: "sessions#login"
    get "session/logout", to: "sessions#logout"
    get "session/user_registration", to: "sessions#user_registration"
    get "session/callback", to: "sessions#callback"
    get "session/refresh_tokens", to: "sessions#refresh_tokens"
  end
end
