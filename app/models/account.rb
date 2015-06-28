class Account < ActiveRecord::Base
  # attr_accessible :title, :body
  include WeixinRailsMiddleware::AutoGenerateWeixinTokenSecretKey
end
