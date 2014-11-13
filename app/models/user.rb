class User < ActiveRecord::Base

  default_scope { by_reputation }

  has_many :answers, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :favorite_questions, dependent: :destroy
  has_many :favorites, through: :favorite_questions, source: :question
  has_many :identities, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :reputations, dependent: :destroy
  has_many :votes, dependent: :destroy

  validates :age, numericality: { only_integer: true }, allow_blank: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { in: 3..64 }, format: { with: /\A[\w\d_]+\z/, message: "allows only latin letters, numbers, and underscore." }

  def after_confirmation
    regular!
  end
  after_update :set_pending_status

  scope :by_reputation, -> { order("reputation_sum DESC") }
  scope :by_registration, -> { unscoped.order(created_at: :desc) }
  scope :alphabetically, -> { unscoped.order("username ASC") }

  enum status: {guest: 0, without_email: 1, pending: 2, regular: 3, admin: 99}

  mount_uploader :avatar, AvatarUploader
  paginates_per 28

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
      :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:facebook, :twitter, :vkontakte, :github]

  def to_param
    username
  end

  def has_favorite?(question_id)
    favorite_ids.include?(question_id) if question_id
  end

  def add_favorite(question_id)
    favorite_questions.create(question_id: question_id) if question_id
  end

  def remove_favorite(question_id)
    favorite_questions.find_by(question_id: question_id).destroy if question_id && has_favorite?(question_id)
  end

  def self.find_for_oauth(auth)
    identity = Identity.find_by(provider: auth.provider, uid: auth.uid)
    return identity.user if identity

    username = "#{auth.provider}_#{auth.uid}"
    user = User.new(email: "#{username}@stackunderflow.dev", username: username, password: Devise.friendly_token)
    user.skip_confirmation!
    user.status = "without_email"
    user.save!
    user.identities.create(provider: auth.provider, uid: auth.uid)
    user
  end

  def reputations_chart_data
    @reputations ||= ReputationChartService.new(self, 30).chart
  end

  private

    def set_pending_status
      if unconfirmed_email_changed? && !unconfirmed_email.nil?
        reset_changes
        pending!
      end
    end
end
