class Category < ActiveRecord::Base
  attr_accessible :name, :display
  validates_presence_of :name
  has_many :templates

  default_scope ->{order('id desc')}
end
