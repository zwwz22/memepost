class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name, :comment => '模板种类名称'
      t.boolean :display, :default => false, :comment => '默认显示这类别的模板'
      t.timestamps
    end
  end
end
