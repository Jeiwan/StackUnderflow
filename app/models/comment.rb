class Comment < ActiveRecord::Base
  include Votable

  default_scope { order("created_at") }

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :body, presence: true, length: { in: 10..5000 }
  
  after_save :update_question_activity

  paginates_per 10

  private
    
    def update_question_activity
      commentable.class.name == "Question" ? commentable.save : commentable.question.save
    end
end
