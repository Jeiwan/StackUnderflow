class CreateReputations < ActiveRecord::Migration
  def change
    create_table :reputations do |t|
      t.integer :value
      t.integer :user_id

      t.timestamps
    end
    add_index :reputations, :user_id
  end
end
