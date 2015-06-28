class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :name, :comment => '问题'
      t.timestamps
    end
  end
end
