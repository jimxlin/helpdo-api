class TodosController < ApplicationController
  before_action :authenticate_user
  before_action :set_todo, only: [:show, :update, :destroy]
  before_action :authorized?, only: [:show, :update, :destroy]
  before_action :member?, only: :show
  before_action :admin?, only: :update
  before_action :creator?, only: :destroy

  # GET /todos
  def index
    @todos = current_user.todos.all
    json_response(@todos)
  end

  # GET /todos/:id
  def show
    json_response(@todo)
  end

  # POST /todos
  def create
    @todo = current_user.todos.create!(todo_params)
    json_response(@todo, :created)
  end

  # PUT /todos/:id
  def update
    @todo.update(todo_params)
    head :no_content
  end

  # DELETE /todos/:id
  def destroy
    @todo.destroy
    head :no_content
  end

  private

  def todo_params
    params.permit(:title, :is_shared)
  end

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def authorized?
    if !@todo.is_shared && @todo.creator.id != current_user.id
      json_response('Not authorized to view or edit this Todo', :unauthorized)
    end
  end

  def member?
    if @todo.is_shared
      unless @todo.members.find_by_id(current_user.id) ||
             @todo.admins.find_by_id(current_user.id)
        json_response('You are not a member of this Todo', :unauthorized)
      end
    end
  end

  def admin?
    if @todo.is_shared
      unless @todo.admins.find_by_id(current_user.id)
        json_response('You are not an admin of this Todo', :unauthorized)
      end
    end
  end

  def creator?
    unless @todo.creator.id == current_user.id
      json_response('Only the creator can destroy the Todo', :unauthorized)
    end
  end
end
