class AssignmentsController < ApplicationController
  before_action :authenticate_user
  before_action :set_task, only: [:index, :create]
  before_action :authorize_member, only: :index
  before_action :authorize_admin, only: [:create, :destroy]

  # GET /public_todos/:public_todo_id/tasks/:task_id/assignments
  def index
    json_response(@task.assigned_members.pluck(:id, :name))
  end

  # POST /public_todos/:public_todo_id/tasks/:task_id/assignments
  def create
    assignee_id = assignment_params[:user_id]
    if member?(assignee_id)
      assignment = @task.assignments.create!(assignment_params)
      json_response(assignment, :created)
    else
      json_response('Assignee is not a member of this Todo', :forbidden)
    end
  end

  # DELETE /public_todos/:public_todo_id/tasks/:task_id/assignments/:id
  def destroy
    Assignment.find(params[:id]).destroy
    head :no_content
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def assignment_params
    params.permit(:user_id)
  end

  def authorize_member
    unless member?(current_user.id)
      json_response('You are not a member of this Todo', :unauthorized)
    end
  end

  def authorize_admin
    todo = PublicTodo.find(params[:public_todo_id])
    unless todo.admins.find_by_id(current_user.id)
      json_response('You are not an admin of this Todo', :unauthorized)
    end
  end

  def member?(user_id)
    todo = PublicTodo.find(params[:public_todo_id])
    todo.members.find_by(id: user_id) || todo.admins.find_by(id: user_id)
  end
end
