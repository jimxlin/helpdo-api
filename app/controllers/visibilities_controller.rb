class VisibilitiesController < ApplicationController
  before_action :authenticate_user
  before_action :set_task, only: [:index, :create]
  before_action :authorize

  # GET /private_todos/:private_todo_id/tasks/:task_id/visibilities
  def index
    json_response(@task.visible_users.pluck(:id, :name))
  end

  # POST /private_todos/:private_todo_id/tasks/:task_id/visibilities
  def create
    friend_id = assignment_params[:user_id].to_i
    if current_user.all_friends.map(&:id).include?(friend_id)
      visibility = @task.visibilities.create!(assignment_params)
      json_response(visibility, :created)
    else
      json_response('Can only share tasks with friends', :forbidden)
    end
  end

  # DELETE /private_todos/:private_todo_id/tasks/:task_id/visibilities/:id
  def destroy
    Visibility.find(params[:id]).destroy
    head :no_content
  end

  private

  def assignment_params
    params.permit(:user_id)
  end

  def set_task
    @task = Task.find(params[:task_id])
  end

  def authorize
    todo = PrivateTodo.find(params[:private_todo_id])
    if todo.creator.id != current_user.id
      json_response('Not authorized to view or edit visibilities for this Task', :unauthorized)
    end
  end
end
