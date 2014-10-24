class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :provider
      t.string :uid
      t.integer :user_id

      t.timestamps
    end
    add_index :identities, :user_id
    add_index :identities, [:provider, :uid]
  end
end
