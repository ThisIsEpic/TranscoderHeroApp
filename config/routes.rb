require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_for :users

  mount Sidekiq::Web => '/sidekiq'

  scope module: :api, defaults: { format: :json } do
    %w(v1).each do |version|
      namespace version do
        resources :jobs do
          post :webhook
        end
      end
    end
  end

  resources :apps, shallow: true do
    resources :job_profiles, path: :profiles
    resources :jobs
  end

  controller :welcome do
    get :dashboard
  end

  root 'welcome#index'
end
