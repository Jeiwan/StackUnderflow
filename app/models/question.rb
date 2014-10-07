class Question < ActiveRecord::Base
  attr_accessor :tag_list

  after_validation :add_tags_from_list

  has_many :answers
  belongs_to :user
  has_many :comments, as: :commentable
  has_and_belongs_to_many :tags
  has_many :attachments, as: :attachable
  accepts_nested_attributes_for :attachments

  validates :body, presence: true, length: { in: 10..5000 }
  validates :title, presence: true, length: { in: 5..512 }
  validates :tag_list, presence: true

  def has_best_answer?
    answers.find_by(best: true) ? true : false
  end

  def form_tag_list
    tags.map(&:name).join(",")
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
