class AddDeltaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :delta, :boolean, default: true, null: false
  end
end
