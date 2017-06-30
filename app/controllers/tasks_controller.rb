class TasksController < ApplicationController
  before_action :authenticate_user
  before_action :set_todo
  before_action :set_todo_task, only: [:show, :update, :destroy]
  before_action :authorize

  # GET /todos/:todo_id/tasks
  def index
    json_response(@todo.tasks)
  end

  # GET /todos/:todo_id/tasks/:id
  def show
    json_response(@task)
  end

  # POST /todos/:todo_id/tasks
  def create
    @todo.tasks.create!(task_params)
    json_response(@todo, :created)
  end

  # PUT /todos/:todo_id/tasks/:id
  def update
    @task.update(task_params)
    head :no_content
  end

  # DELETE /todos/:todo_id/tasks/:id
  def destroy
    @task.destroy
    head :no_content
  end

  private

  def task_params
    params.permit(:name, :is_done)
  end

  def set_todo
    if params[:private_todo_id]
      @todo = Todo.find(params[:private_todo_id])
    else
      @todo = Todo.find(params[:public_todo_id])
    end
  end

  def set_todo_task
    @task = @todo.tasks.find_by!(id: params[:id]) if @todo
  end

  def authorize
    if (@todo.type == 'PublicTodo' && !@todo.admins.find_by(id: current_user.id)) ||
       (@todo.type == 'PrivateTodo' && @todo.creator.id != current_user.id)
      json_response('Not authorized to change this task', :unauthorized)
    end
  end
end
