Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  devise_for :users, path: '', path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      registration: 'signup'
    },
    controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }

  resources :users, only: [] do
    get 'budget', to: 'users/users#show_budget'
  end

  resources :categories, only: %i[index show create update destroy]

  resources :expenses, only: %i[index show create update destroy] do
    collection do
      get :filter
    end
  end
end
