Rails.application.routes.draw do
  resources :users, only: [:index, :create]# TODO , :update, :destroy]
  get 'visible_tasks', to: 'users#visible_tasks'
  resources :friendships, only: [:index, :create, :update, :destroy]
  post 'user_token', to: 'user_token#create'
  resources :private_todos, only: [:index, :create, :update, :destroy] do
    resources :tasks, only: [:index, :show, :create, :update, :destroy] do
      resources :visibilities, only: [:index, :create, :destroy]
    end
  end
  resources :public_todos, only: [:index, :create, :update, :destroy] do
    resources :tasks, only: [:index, :show, :create, :update, :destroy] do
      resources :assignments, only: [:index, :create, :destroy]
    end
    resources :memberships, only: [:index, :create, :update, :destroy]
  end
end
