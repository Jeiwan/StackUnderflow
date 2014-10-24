class User < ActiveRecord::Base

  has_many :questions
  has_many :answers
  has_many :comments
  has_many :votes
  has_many :attachments
  has_many :identities

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
      :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:facebook, :twitter, :vkontakte]

  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { in: 3..32 }, format: { with: /\A[\w\d_]+\z/, message: "allows only latin letters, numbers, and underscore." }

  mount_uploader :avatar, AvatarUploader

  def to_param
    username
  end

  def self.find_for_oauth(auth)
    identity = Identity.find_by(provider: auth.provider, uid: auth.uid)
    return identity.user if identity

    user = User.find_by(email: auth.info[:email])
    unless user
      password = Devise.friendly_token
      username = "#{auth.provider}_#{auth.uid}"
      user = User.create(email: auth.info[:email] || "#{username}@localhost.localhost", username: username, password: password)
    end
    user.identities.create(provider: auth.provider, uid: auth.uid)
    user
  end
end
