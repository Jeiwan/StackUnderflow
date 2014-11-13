class AnswerMailer < ActionMailer::Base
  default from: "noreply@stackunderflow.com"

  def new_for_subscribers(user, question)
    @user = user
    @question = question
    mail to: user.email, subject: "New answer to one of your favorite questions!"
  end

  def new_for_question_author(user, question)
    @user = user
    @question = question
    mail to: user.email, subject: "New answer to your question!"
  end
end
