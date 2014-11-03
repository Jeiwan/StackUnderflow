class AddQuestionsCountToTags < ActiveRecord::Migration
  def change
    add_column :tags, :questions_count, :integer, default: 0
    add_index :tags, :questions_count
  end
end
