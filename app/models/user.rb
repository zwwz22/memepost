class User < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :orders
  belongs_to :account


  def self.find_or_create_by_user_info(info,account_id)
    if User.find_all_by_openid(info['openid']).blank?
      user = User.new
      user.unionid  = info['unionid']
      user.openid   = info['openid']
      user.nickname = info['nickname']
      user.sex      = info['sex']
      user.city     = info['city']
      user.province = info['province']
      user.country  = info['country']
      user.headimgurl = info['headimgurl']
      user.account_id = account_id
      user.save
      user
    else
      User.find_by_openid(info['openid'])
    end
  end

  def address
   "#{ self.country } #{self.province} #{self.city}"

  end
end
