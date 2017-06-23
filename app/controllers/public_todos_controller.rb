class PublicTodosController < ApplicationController
  before_action :authenticate_user
  before_action :set_todo, only: [:show, :update, :destroy]
  before_action :authorize_member, only: [:show]
  before_action :authorize_creator, only: [:update, :destroy]

  # GET /public_todos
  def index
    todos = current_user.public_todos.all
    json_response(todos)
  end

  # GET /public_todos/:id
  # TODO necessary for the api?, can fetch tasks directly with index info
  def show
    json_response(@todo)
  end

  # POST /public_todos
  def create
    @todo = current_user.todos.create!(todo_params)
    json_response(@todo, :created)
  end

  # PUT /public_todos/:id
  def update
    @todo.update(todo_params)
    head :no_content
  end

  # DELETE /public_todos/:id
  def destroy
    @todo.destroy
    head :no_content
  end

  private

  def todo_params
    params.permit(:title, :type)
  end

  def set_todo
    @todo = PublicTodo.find(params[:id])
  end

  def authorize_member
    unless @todo.memberships.find_by(user_id: current_user.id)
      json_response('Not authorized to view or edit this Todo', :unauthorized)
    end
  end

  def authorize_creator
    if @todo.creator.id != current_user.id
      json_response('Not authorized to view or edit this Todo', :unauthorized)
    end
  end
end
