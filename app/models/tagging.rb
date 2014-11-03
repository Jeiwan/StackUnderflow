class Tagging < ActiveRecord::Base
  belongs_to :question
  belongs_to :tag, counter_cache: :questions_count
end
