Rails.application.routes.draw do
  devise_for :users, class_name: "Oauth::User"
  get "oauth/authorize", to: "oauth#authorize"
  get "oauth/redirect_to_client", to: "oauth#redirect_to_client"

  namespace :client do
    root "pages#index"
    get "oauth/login", to: "oauth#login"
    get "oauth/logout", to: "oauth#logout"
    get "oauth/user_registration", to: "oauth#user_registration"
    get "oauth/callback", to: "oauth#callback"
  end
end
