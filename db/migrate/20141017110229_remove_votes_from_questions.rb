class RemoveVotesFromQuestions < ActiveRecord::Migration
  def change
    remove_column :questions, :votes
  end
end
