class AddAnswersCountToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :answers_count, :integer, default: 0, null: false
  end
end
