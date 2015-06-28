class User < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :orders


  def self.find_or_create_by_user_info(info)
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
      user.save
      user
    else
      User.find_by_openid(info['openid'])
    end
  end
end
