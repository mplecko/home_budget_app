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

  namespace :users do
    resource :maximum_budgets, only: %i[show update], controller: 'maximum_budgets'
    resource :remaining_budgets, only: %i[show], controller: 'remaining_budgets'
  end

  resources :categories, only: %i[index show create update destroy]

  resources :expenses, only: %i[index show create update destroy] do
    collection do
      get :filter
    end
  end
end
