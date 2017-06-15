Rails.application.routes.draw do
  resources :users, only: [:index, :create, :update, :destroy]
  resources :friendships, only: [:index, :create, :update, :destroy]
  post 'user_token' => 'user_token#create'
  resources :todos do
    resources :tasks
    resources :memberships
  end
end
