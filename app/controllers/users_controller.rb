class UsersController < ApplicationController
  # TODO implement search users feature
  
  # GET /users?query=...
  def index
    # params[:query]
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
      :password_confirmation
    )
  end
end
