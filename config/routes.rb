Rails.application.routes.draw do
  root to: 'pages#home'

  resources :projects, only: [:new, :create, :show, :update]
end
