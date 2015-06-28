class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :scope, :string, :comment => '授权的作用域'
    add_column :users, :access_token,   :string, :comment => 'access_token'
    add_column :users, :refresh_token,  :string, :comment => '刷新access_token'
    add_column :users, :country,        :string, :comment => '国家'
    add_column :users, :province,       :string, :comment => '省份'
    add_column :users, :city,           :string, :comment => '市'
    add_column :users, :account_id,     :integer, :comment => '公众号ID'
  end
end
