class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :nickname,    :comment => '用户昵称'
      t.string  :headimgurl,  :comment => '用户头像'
      t.string  :openid,      :comment => '用户唯一标识'
      t.string  :unionid,     :comment => '全局唯一标识'
      t.boolean :sex,         :comment => '性别'

      t.timestamps
    end
  end
end
