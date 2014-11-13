class Ability
  include CanCan::Ability

  def initialize(user)
    return guest_abilities if user.nil?

    @user = user

    case user.status
    when "guest"
      guest_abilities
    when "without_email"
      without_email_abilities
    when "pending"
      pending_abilities
    when "regular"
      regular_abilities
    when "admin"
      admin_abilities
    end
  end

  def guest_abilities
    can :read, [Question, Answer, Comment, User, Tag]
    can [:popular, :unanswered, :active, :tagged], Question
    can [:by_registration, :alphabetically], User
    can [:popular, :newest], Tag
  end

  def without_email_abilities
    guest_abilities

    can :update, User, id: @user.id
    can :profile, User, id: @user.id
  end

  def pending_abilities
    without_email_abilities
  end

  def regular_abilities
    pending_abilities

    can :create, [Answer, Attachment, Comment, Question, Tag, Vote]
    can :create, Identity, user: @user

    can :logins, User, id: @user.id

    can :update, [Question, Answer, Comment], user: @user

    can :destroy, [Question, Answer, Comment, Attachment], user: @user

    can :vote_up, [Question, Answer, Comment] do |resource|
      resource.user != @user && !resource.voted_by?(@user)
    end

    can :vote_down, [Question, Answer, Comment] do |resource|
      resource.user != @user && !resource.voted_by?(@user)
    end

    can :mark_best, Answer do |answer|
      answer.question.user == @user && !answer.best? && !answer.question.has_best_answer?
    end

    can :add_favorite, Question
    can :remove_favorite, Question
  end

  def admin_abilities
    can :manage, :all
  end
end
