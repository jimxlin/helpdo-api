class FriendshipsController < ApplicationController
  before_action :authenticate_user
  before_action :set_friendship, only: [:update, :destroy]

  # POST /friendships
  def create
    @friendship = current_user.friendships.create!(friendship_params)
    json_response(@friendship, :created)
  end

  # PUT /friendships/:id
  def update
    # user cannot accept a friend request that they initiated
    if @friendship.user_id == current_user.id
      json_response('Cannot accept own friend request', :unauthorized)
    else
      @friendship.update!(friendship_params) # what if friendship row no longer exists
      head :no_content
    end
  end

  # DELETE /friendships/:id
  def destroy
    @friendship.destroy
    head :no_content
  end

  private

  def friendship_params
    params.permit(:friend_id, :is_accepted)
  end

  def set_friendship
    @friendship = Friendship.find(params[:id])
  end
end
