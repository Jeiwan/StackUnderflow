class AddUserIdToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :user_id, :integer
    add_index :attachments, :user_id
  end
end
