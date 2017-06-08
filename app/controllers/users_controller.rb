class UsersController < ApplicationController

  def create
    user = User.new(user_params)
    if user.save
      render json: {}, status: 200
    else
      render json: user.errors.to_json, status: 422
    end
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
