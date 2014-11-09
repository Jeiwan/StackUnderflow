class User < ActiveRecord::Base

  enum status: {guest: 0, without_email: 1, pending: 2, regular: 3, admin: 99}

  default_scope { by_reputation }
  scope :by_reputation, -> { order("reputation_sum DESC") }
  scope :by_registration, -> { unscoped.order("created_at DESC") }
  scope :alphabetically, -> { unscoped.order("username ASC") }
  paginates_per 30

  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :attachments, dependent: :destroy
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
