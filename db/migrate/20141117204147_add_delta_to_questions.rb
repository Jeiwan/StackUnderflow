class AddDeltaToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :delta, :boolean, default: true, null: false
  end
end
