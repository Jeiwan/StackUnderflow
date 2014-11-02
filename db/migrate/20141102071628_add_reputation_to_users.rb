class AddReputationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reputation, :integer, default: 0, nil: false
  end
end
