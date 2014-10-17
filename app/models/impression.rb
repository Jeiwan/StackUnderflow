class Impression < ActiveRecord::Base
  belongs_to :question
  belongs_to :user

  validates :remote_ip, presence: true
  validates :user_agent, presence: true
end
