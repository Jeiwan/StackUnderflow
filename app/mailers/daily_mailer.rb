class DailyMailer < ActionMailer::Base
  default from: "noreply@stackunderflow.com"

  def digest(user, questions)
    @user = user
    @questions = questions

    mail to: user.email
  end
end
