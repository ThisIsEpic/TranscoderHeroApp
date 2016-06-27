Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_for :users

  scope module: :api, defaults: { format: :json } do
    %w(v1).each do |version|
      namespace version do
        resources :jobs
      end
    end
  end

  resources :apps, shallow: true do
    member do
      post :set_default
    end
    resources :job_profiles, path: :profiles
    resources :jobs
  end

  controller :welcome do
    get :dashboard
  end

  root 'welcome#index'
end
