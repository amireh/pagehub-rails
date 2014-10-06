Rails.application.routes.draw do
  devise_for :users

  root 'guest#index'
end
