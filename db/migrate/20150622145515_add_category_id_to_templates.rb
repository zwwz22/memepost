class AddCategoryIdToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :category_id, :integer,:comment => '类型ID'
  end
end
