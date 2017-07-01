Rails.application.routes.draw do
  resources :users, only: [:index, :create, :update, :destroy]
  resources :friendships, only: [:index, :create, :update, :destroy]
  post 'user_token' => 'user_token#create'
  # index '' => ''
  resources :private_todos, only: [:index, :show, :create, :update, :destroy] do
    resources :tasks, only: [:index, :show, :create, :update, :destroy] do
      resources :visibilities, only: [:index, :create, :destroy]
    end
  end
  resources :public_todos, only: [:index, :show, :create, :update, :destroy] do
    resources :tasks, only: [:index, :show, :create, :update, :destroy] do
      resources :assignments, only: [:index, :create, :destroy]
    end
    resources :memberships, only: [:index, :create, :update, :destroy]
  end
end
