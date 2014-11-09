Rails.application.routes.draw do
  root to: "pages#home"

  resources :projects do
    collection do
      post 'add_target_user'
    end
  end
end
