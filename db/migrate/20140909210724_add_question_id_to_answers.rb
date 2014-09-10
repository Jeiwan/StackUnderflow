class AddQuestionIdToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :question_id, :integer
    add_index :answers, :question_id
  end
end
