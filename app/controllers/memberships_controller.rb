class MembershipsController < ApplicationController
  before_action :authenticate_user
  before_action :set_todo
  before_action :set_membership, only: [:update, :delete]
  before_action :authorize_member
  before_action :authorize_admin, only: [:create, :update, :delete]

  # GET /todos/:todo_id/memberships
  def index
    all_members = {
      admins: @todo.admins.pluck(:id, :name, :bio),
      members: @todo.members.pluck(:id, :name, :bio)
    }
    json_response(all_members.to_json)
  end

  # POST /todos/:todo_id/memberships
  def create
    membership = @todo.memberships.create(membership_params)
    json_response(membership, :created)
  end

  # PUT todos/:todo_id/memberships/:id
  # TODO who gets to give / remove admin permissions?
  def update
    @membership.update!(membership_params)
  end

  private

  def membership_params
    params.permit(:user_id, :is_admin)
  end

  def set_todo
    @todo = Todo.find(params[:todo_id])
  end

  def set_membership
    @membership = Membership.find(params[:id])
  end

  def authorize_member
    unless @todo.members.find_by_id(current_user.id) ||
           @todo.admins.find_by_id(current_user.id)
      json_response('You are not a member of this Todo', :unauthorized)
    end
  end

  def authorize_admin
    unless @todo.admins.find_by_id(current_user.id)
      json_response('You are not an admin of this Todo', :unauthorized)
    end
  end
end
