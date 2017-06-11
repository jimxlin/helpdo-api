Rails.application.routes.draw do
  resources :users
  resources :friendships
  post 'user_token' => 'user_token#create'
  resources :todos do
    resources :tasks
  end
end
