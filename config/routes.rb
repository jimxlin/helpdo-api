Rails.application.routes.draw do
  resources :users, only: [:index, :create, :update, :destroy]
  resources :friendships, only: [:index, :create, :update, :destroy]
  post 'user_token' => 'user_token#create'
  # TODO trim resourceful routes
  resources :private_todos do
    resources :tasks
  end
  resources :public_todos do
    resources :tasks do
      resources :assignments
    end
    resources :memberships
  end
end
