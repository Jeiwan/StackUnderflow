class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_parent
  before_action :votable_doesnt_belong_to_current_user?

  def vote_up
    @parent.vote_up current_user
    publish_and_return_votes
  end

  def vote_down
    @parent.vote_down current_user
    publish_and_return_votes
  end

  private
    def votable_doesnt_belong_to_current_user?
      if @parent.user == current_user
        render json: :nothing, status: 403
      end
    end

    def publish_and_return_votes
      PrivatePub.publish_to "/#{@parent.class.name.to_s.downcase.pluralize}/#{@parent.id}", votes: @parent.total_votes
      render json: {votes: @parent.total_votes}, status: 200
    end
end
