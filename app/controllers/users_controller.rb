class UsersController < ApplicationController
  before_action :authenticate_user, only: [:index, :visible_tasks]

  # GET /users?query=...
  def index
    query = params[:query]
    if query
      users = User.where(name: query.downcase).pluck(:id, :name, :bio)
      json_response(users)
    else
      json_response([])
    end
  end

  # GET /visible_tasks
  def visible_tasks
    json_response(current_user.visible_tasks)
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
