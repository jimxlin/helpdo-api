Rails.application.routes.draw do
  resources :users
  post 'user_token' => 'user_token#create'
end
