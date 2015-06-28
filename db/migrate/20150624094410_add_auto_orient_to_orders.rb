class AddAutoOrientToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :auto_orient, :boolean, :default => false, :comment => '自动旋转'
  end
end
