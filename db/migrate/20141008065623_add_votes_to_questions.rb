class AddVotesToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :votes, :integer, default: 0, null: false
  end
end
