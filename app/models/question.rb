class Question < ActiveRecord::Base
  include Votable

  default_scope { order("created_at DESC") }
  scope :tagged_with, ->(tag) { unscoped.joins(:tags).where("tags.name = ?", tag) }
  scope :popular, -> { unscoped.order("votes_sum DESC, created_at DESC") }
  scope :unanswered, -> { where("answers_count = 0") }
  scope :active, -> { unscoped.order("recent_activity DESC, created_at DESC") }

  before_save :set_recent_activity

  belongs_to :user
  has_many :taggings
  has_many :tags, through: :taggings
  has_many :answers, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :impressions, dependent: :destroy
  accepts_nested_attributes_for :attachments, reject_if: proc { |attrs| attrs['file'].blank? && attrs['file_cache'].blank? }

  validates :body, presence: true, length: { in: 10..5000 }
  validates :title, presence: true, length: { in: 5..512 }
  validates :tag_list, presence: true

  def has_best_answer?
    answers.find_by(best: true) ? true : false
  end

  def tag_list
    tags.map(&:name).join(",")
  end

  def tag_list=(list)
    list ||= ""
    names = list.split(",").map { |n| n.strip.downcase.tr(" ", "-") }.uniq
    self.tags = names.map { |name| new_tag = Tag.find_or_create_by(name: name) }
  end

  private

    def set_recent_activity
      self.recent_activity = Time.zone.now
    end
end
