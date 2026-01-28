Rails.application.routes.draw do
  devise_for :users
  root "pages#index"
  get "oauth/authorize", to: "oauth#authorize"
end
