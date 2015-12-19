Rails.application.routes.draw do
  root to: 'pages#home'

  resources :projects, only: [:new, :create, :show] do
    member do
      post 'source'
      patch 'target'
    end
  end
end
