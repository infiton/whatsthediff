Rails.application.routes.draw do
  root to: "pages#home"

  resources :projects do
    member do
      post 'add_target_user'
      post 'upload_source_data'
    end
  end
end
