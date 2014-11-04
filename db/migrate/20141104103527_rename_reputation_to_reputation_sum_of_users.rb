class RenameReputationToReputationSumOfUsers < ActiveRecord::Migration
  def change
    rename_column :users, :reputation, :reputation_sum
  end
end
