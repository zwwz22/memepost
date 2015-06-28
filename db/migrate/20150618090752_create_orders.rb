class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer "user_id", :null => false, :comment => "用户id"
      t.integer "account_id", :null => false, :comment => "来源公众账号id"
      t.string "osn", :limit => 16, :null => false, :comment => "订单号"
      t.string "state", :comment => "状态"
      t.decimal "price", :comment => "价值"
      t.string "receiver", :comment => "收件人姓名"
      t.string "receiver_province", :comment => "收件人姓名省"
      t.string "receiver_city", :comment => "收件人姓名市"
      t.string "receiver_county", :comment => "收件人姓名区/县"
      t.string "receiver_address", :comment => "收件人详细地址"
      t.string "receiver_post_no", :comment => "收件人邮编"
      t.string "sender", :limit => 16, :comment => "寄件人姓名"
      t.string "sender_province", :comment => "寄件人省"
      t.string "sender_city", :comment => "寄件人市"
      t.string "sender_county", :comment => "寄件人区/县"
      t.string "sender_address", :comment => "寄件人详细地址"
      t.string "sender_post_no", :comment => "寄件人邮编"
      t.datetime "purchased_at", :comment => "付款时间"
      t.string "pay_way", :comment => "支付方式"
      t.string "blessings", :comment => "祝福语"
      t.string "back_image_url", :comment => "背面图片地址"

      #####明信片属性
      t.string   :x
      t.string   :pos_x
      t.string   :y
      t.string   :pos_y
      t.string   :scale
      t.string   :scale_card
      t.string   :rotation
      t.integer  :template_id
      t.string   :front_image_url
      t.string   :back_image_url

      ##微信js api
      t.string   :image_url, :comment => '上传的图片地址'
      t.string   :media_id,  :comment => '微信下载图片需要的media_id'
      t.string   :local_id,  :comment => '本地图片id'
      t.string   :voice_url, :comment => '声音地址'
      t.string   :voice_media_id, :comment => '下载声音的media_id'
      t.string   :voice_local_id, :comment => '本地声音id'
      ####
      t.timestamps
    end
  end
end
