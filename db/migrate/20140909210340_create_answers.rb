class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.text :body

      t.timestamps
    end
  end
end
