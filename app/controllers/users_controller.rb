class UsersController < ApplicationController
  before_action :authenticate_user, only: [:index]

  # GET /users?query=...
  def index
    query = params[:query]
    users = User.where(name: query.downcase).pluck(:id, :name, :bio)
    json_response(users)
  end

  # POST /users
  def create
    user = User.create!(user_params)
    json_response(user, :created)
  end

  private

  def user_params
    params.permit(
      :name,
      :email,
      :password,
      :password_confirmation,
      :bio
    )
  end
end
