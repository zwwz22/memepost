class AddSecretToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :qr_url,     :string,  :comment => '声音二维码地址'
    add_column :orders, :has_secret, :boolean, :default => false, :comment => '是否设置问答'
    add_column :orders, :answer,     :string,  :comment => '答案'
    add_column :orders, :question_id, :integer, :comment => '提问的ID'
  end
end
