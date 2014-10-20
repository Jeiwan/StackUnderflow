class AddRecentActivityToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :recent_activity, :datetime, default: nil
  end
end
