class Question < ActiveRecord::Base
  attr_accessor :tag_list

  after_validation :add_tags_from_list

  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :answers, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy
  accepts_nested_attributes_for :attachments

  validates :body, presence: true, length: { in: 10..5000 }
  validates :title, presence: true, length: { in: 5..512 }
  validates :tag_list, presence: true, on: :create

  def has_best_answer?
    answers.find_by(best: true) ? true : false
  end

  def form_tag_list
    tags.map(&:name).join(",")
  end

  def vote_up(user)
    unless voted_by? user
      votes.create(user_id: user.id, vote: 1)
    end
  end

  def vote_down(user)
    unless voted_by? user
      votes.create(user_id: user.id, vote: -1)
    end
  end

  def total_votes
    votes.inject(0) { |s, v| s + v.vote }
  end

  def voted_by?(user)
    votes.find_by_user_id(user) ? true : false
  end

  private

    def add_tags_from_list
      if tag_list.present?
        tags.clear
        tag_list.split(",").each do |tag|
          t = Tag.find_by_name(tag) || Tag.create(name: tag)
          if t.valid?
            tags << t
          else
            errors[:tag_list] << "Tags #{t.errors['name'][0]}"
          end
        end
      end
    end
end
