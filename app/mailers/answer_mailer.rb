class AnswerMailer < ActionMailer::Base
  default from: "noreply@stackunderflow.com"

  def new_for_subscribers(user, question)
    @user = user
    @question = question
    subject = question.user == user ? "New answer to your question!" : "New answer to one of your favorite questions!"
    mail to: user.email, subject: subject
  end
end
