class AddAdditionalInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :website, :string
    add_column :users, :location, :string
    add_column :users, :age, :integer
    add_column :users, :full_name, :string
  end
end
