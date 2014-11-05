class User < ActiveRecord::Base

  enum status: {guest: 0, without_email: 1, pending: 2, regular: 3, admin: 99}

  default_scope { by_reputation }
  scope :by_reputation, -> { order("reputation_sum DESC") }
  scope :by_registration, -> { unscoped.order("created_at DESC") }
  scope :alphabetically, -> { unscoped.order("username ASC") }

  has_many :questions
  has_many :answers
  has_many :comments
  has_many :votes
  has_many :attachments
  has_many :identities, dependent: :destroy
  has_many :reputations, dependent: :destroy

  after_update :set_pending_status
  def after_confirmation
    regular!
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
      :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:facebook, :twitter, :vkontakte, :github]

  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { in: 3..64 }, format: { with: /\A[\w\d_]+\z/, message: "allows only latin letters, numbers, and underscore." }
  validates :age, numericality: { only_integer: true }, allow_blank: true

  mount_uploader :avatar, AvatarUploader

  def to_param
    username
  end

  def self.find_for_oauth(auth)
    identity = Identity.find_by(provider: auth.provider, uid: auth.uid)
    return identity.user if identity

    username = "#{auth.provider}_#{auth.uid}"
    email = "#{username}@stackunderflow.dev"
    password = Devise.friendly_token
    user = User.new(email: email, username: username, password: password)
    user.skip_confirmation!
    user.status = "without_email"
    user.save!
    user.identities.create(provider: auth.provider, uid: auth.uid)
    user
  end

  def reputations_chart_data
    unless @reputations
      @reputations = reputations.select("cast(created_at as date)", "sum(value) as value").where("created_at >= ?", 30.days.ago).group("cast(created_at as date)").order("sum(value) DESC")
      max = @reputations[0].value
      @reputations = @reputations.map { |r| {percentage: ((r.value / max.to_f * 100).round(2)), reputation: r.value, date: r.created_at} }
      @reputations = (29.days.ago.to_date..Date.today).map do |date|
        reputation = @reputations.select { |r| r[:date] == date }
        reputation[0] ? reputation[0] : {date: date, reputation: 0, percentage: 0}
      end
    end
    @reputations
  end

  private

    def set_pending_status
      if unconfirmed_email_changed? && !unconfirmed_email.nil?
        reset_changes
        pending!
      end
    end
end
