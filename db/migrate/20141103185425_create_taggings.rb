class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.integer :question_id
      t.integer :tag_id
    end
    add_index :taggings, [:question_id, :tag_id], unique: true
  end
end
