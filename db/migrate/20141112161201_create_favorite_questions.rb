class CreateFavoriteQuestions < ActiveRecord::Migration
  def change
    create_table :favorite_questions do |t|
      t.integer :question_id
      t.integer :user_id

      t.timestamps
    end

    add_index :favorite_questions, :user_id
    add_index :favorite_questions, :question_id
    add_index :favorite_questions, [:question_id, :user_id], unique: true
  end
end
