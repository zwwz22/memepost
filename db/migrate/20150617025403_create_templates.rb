class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string "name", :limit => 32, :null => false, :comment => "模板名称"
      t.string "image_url", :null => false, :comment => "模板图片"
      t.string "type", :limit => 128, :default => "postcard", :null => false, :comment => "模板类型postcard"
      t.string "area_width", :limit => 32, :comment => "模板区域宽"
      t.string "area_height", :limit => 32, :comment => "模板区域高"
      t.string "area_x", :limit => 32, :comment => "模板区域位置x"
      t.string "area_y", :limit => 32, :comment => "模板区域位置y"
      t.boolean "is_horizontal", :default => false, :comment => "是否是横向模板"
      t.boolean "has_text", :default => false, :comment => "文字留言功能"
      t.string "text_x", :comment => "起始坐标X"
      t.string "text_y", :comment => "起始左边Y"
      t.string "text_w", :comment => "宽"
      t.string "text_h", :comment => "高"
      t.string "text_color", :comment => "文字颜色"
      t.string "default_text", :comment => '默认文字'
      t.timestamps
    end
  end
end
