Rails.application.routes.draw do
  root to: 'pages#home'

  resources :projects, only: [:new, :create, :show, :update] do
    resources :project_results, only: [:show]
  end
end
