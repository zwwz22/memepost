class Template < ActiveRecord::Base
  attr_accessible :image_url,:name,:area_height,:area_width,:area_x,:area_y,:is_horizontal,:category_id
  validates_presence_of :image_url,:name

  belongs_to :category
  has_many   :orders
  self.inheritance_column = :_type_disabled
  default_scope -> {order('id desc')}
end
