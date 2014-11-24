Rails.application.routes.draw do
  root to: "pages#home"

  get "/faq" => "pages#faq"
  get "/learn_more" => "pages#learn_more"

  resources :projects do
    member do
      post 'add_target_user'
      post 'upload_source_data'
      post 'upload_target_data'
      get  'calculate_difference'
      get  'download'
    end
  end
end
