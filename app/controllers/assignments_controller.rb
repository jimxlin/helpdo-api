class AssignmentsController < ApplicationController
  before_action :authenticate_user
  before_action :set_task, only: [:index, :create]
  before_action :authorize_member, only: :index
  before_action :authorize_admin, only: [:create, :destroy]

  # GET /public_todos/:public_todo_id/tasks/:task_id/assignments
  def index
    json_response(@task.assignments)
  end

  # POST /public_todos/:public_todo_id/tasks/:task_id/assignments
  def create
    assignment = @task.assignments.create!(assignment_params)
    json_response(assignment, :created)
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
    todo = PublicTodo.find(params[:public_todo_id])
    unless todo.members.find_by_id(current_user.id) ||
           todo.admins.find_by_id(current_user.id)
      json_response('You are not a member of this Todo', :unauthorized)
    end
  end

  def authorize_admin
    todo = PublicTodo.find(params[:public_todo_id])
    unless @todo.admins.find_by_id(current_user.id)
      json_response('You are not an admin of this Todo', :unauthorized)
    end
  end
end
