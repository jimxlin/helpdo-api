class MembershipsController < ApplicationController
  before_action :authenticate_user
  before_action :set_todo
  before_action :set_membership, only: [:update, :destroy]
  before_action :authorize_member
  before_action :authorize_admin, only: [:create, :update, :destroy]

  # GET /public_todos/:todo_id/memberships
  def index
    all_members = {
      admins: @todo.admins.pluck(:id, :name, :bio),
      members: @todo.members.pluck(:id, :name, :bio)
    }
    json_response(all_members)
  end

  # POST /public_todos/:todo_id/memberships
  def create
    membership = @todo.memberships.create!(membership_params)
    json_response(membership, :created)
  end

  # PUT /public_todos/:todo_id/memberships/:id
  def update
    if @membership.user_id == @todo.creator.id
      json_response('Cannot change creator membership', :forbidden)
    else
      @membership.update!(update_membership_params)
      head :no_content
    end
  end

  # DELETE /public_todos/:public_todo_id/memberships/:id
  def destroy
    if @membership.user_id == @todo.creator.id
      json_response('Cannot destroy creator membership', :forbidden)
    else
      @membership.destroy
      head :no_content
    end
  end

  private

  def membership_params
    params.permit(:user_id, :is_admin)
  end

  def update_membership_params
    params.permit(:is_admin)
  end

  def set_todo
    @todo = PublicTodo.find(params[:public_todo_id])
  end

  def set_membership
    @membership = Membership.find(params[:id])
  end

  def authorize_member
    unless @todo.members.find_by(id: current_user.id) ||
           @todo.admins.find_by(id: current_user.id)
      json_response('You are not a member of this Todo', :unauthorized)
    end
  end

  def authorize_admin
    unless @todo.admins.find_by_id(current_user.id)
      json_response('You are not an admin of this Todo', :unauthorized)
    end
  end
end
