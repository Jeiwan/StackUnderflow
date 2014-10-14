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
    question_id = case @parent.class.name
                  when 'Question' then @parent.id
                  when 'Answer' then @parent.question.id
                  when 'Comment' then @parent.commentable.class.name == 'Question' ? @parent.commentable.id : @parent.commentable.question.id
                  end

      PrivatePub.publish_to "/questions/#{question_id}", vote: @parent.total_votes, parent: @parent.class.name, parent_id: @parent.id
      render json: {votes: @parent.total_votes}, status: 200
    end
end
