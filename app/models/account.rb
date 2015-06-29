class Account < ActiveRecord::Base
  # attr_accessible :title, :body
  include WeixinRailsMiddleware::AutoGenerateWeixinTokenSecretKey

  has_many :users
  has_many :orders
end
