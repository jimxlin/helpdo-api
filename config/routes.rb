Rails.application.routes.draw do
  resources :users
  resources :friendships, only: [:index, :create, :update, :destroy]
  post 'user_token' => 'user_token#create'
  resources :todos do
    resources :tasks
  end
end
