class AddEditedAtToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :edited_at, :datetime, default: nil
  end
end
