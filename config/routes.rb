Rails.application.routes.draw do
  devise_for :users, class_name: "Oauth::User"
  root "pages#index"
  get "oauth/authorize", to: "oauth#authorize"
  get "oauth/callback", to: "oauth#callback"
end
