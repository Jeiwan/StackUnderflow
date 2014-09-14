class AddUserIdToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :user_id, :integer
    add_index :questions, :user_id
  end
end
