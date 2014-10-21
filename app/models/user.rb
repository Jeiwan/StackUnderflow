class User < ActiveRecord::Base

  has_many :questions
  has_many :answers
  has_many :comments
  has_many :votes
  has_many :attachments

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { in: 3..16 }, format: { with: /\A[\w\d_]+\z/, message: "allows only latin letters, numbers, and underscore." }

  mount_uploader :avatar, AvatarUploader
end
