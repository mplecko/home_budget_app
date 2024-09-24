Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  resources :categories, only: %i[index show create update destroy]
  resources :expenses, only: %i[index show create update destroy] do
    collection do
      get :filter
    end
  end
end
