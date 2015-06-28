require 'open-uri'
class Order < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :template
  belongs_to :user

  class << self
      def recent
        where("created_at >= ?",(Time.now.beginning_of_day - 6.days))
      end
  end


  state_machine :initial => :incomplete do

    #提交订单生成对应图片正面
    event :gen_image do
      transition :incomplete => :created
    end

    #生成地址信息
    event :gen_address do
      transition :created   => :created_address
    end

    #生成祝福语
    event :gen_blessings do
      transition :created_address   => :created_blessings
    end

    #订单完成
    event :successful do
      transition :created_blessings   => :success
    end

    #重新生成正面图
    event :back do
      transition [:created,:created_address,:created_blessings,:success]  => :incomplete
    end

    after_transition :incomplete => :created do |order|
      # 生成图片
      image_url = order.create_front_image
      order.front_image_url = image_url
      order.save!
    end

    after_transition any => :success do |order|
      # 生成图片
      if order.voice_media_id.present?
        voice_url,qr_url = Order.wx_voice_download(order)
        order.voice_url  = voice_url
        order.qr_url     = qr_url
      end
      back_image_url = order.create_back_image
      order.back_image_url = back_image_url
      order.save!
    end
  end

  def create_front_image

    template = self.template

    DavinciRubyClientSDK::Setting.app_key        = 'memeing'
    DavinciRubyClientSDK::Setting.app_secret     = 'xE7xkJhvy7cHxuI'
    DavinciRubyClientSDK::Setting.server_address = 'http://davinci.memeing.cn'

    blueprints = Array.new

    # 正面
    pic_a_blueprint = DavinciRubyClientSDK::Blueprint::new('pic_a')

    pic_a_blueprint.canvas do |option|
      option.add_canvas_option :width, 1000
      option.add_canvas_option :height, 1500
    end

    pic_a_blueprint.add_layer 1 do |layer|
      layer.technique = :draw_image
      layer.add_inspiration :image_url,  self.image_url
      layer.add_inspiration :resize,     (self.scale_card.to_f / self.scale.to_f * 100).to_s + '%'
      layer.add_inspiration :position_x, (template.area_x.to_f + self.x.to_f / self.scale.to_f)
      layer.add_inspiration :position_y, (template.area_y.to_f + self.y.to_f / self.scale.to_f)
      layer.add_inspiration :rotate,     self.rotation.to_f
      layer.add_inspiration :dao, 1 unless self.auto_orient# 关闭自动旋转
    end

    pic_a_blueprint.add_layer 10 do |layer|
      layer.technique = :draw_image
      layer.add_inspiration :image_url, template.image_url
      layer.add_inspiration :position_x, 0
      layer.add_inspiration :position_y, 0
    end

    pic_a_blueprint.mount do |option|
      option.add_mount_option :ext, 'jpg'
      option.add_mount_option :quality, 75
    end

    blueprints << pic_a_blueprint.to_blueprint

    # 同步处理
    api = DavinciRubyClientSDK::API.new
    error, result = api.draw("#{self.osn}", blueprints.to_json).call

    if error.nil?
      result = JSON.parse result
      result['results'][0]['url']
    else
      Rails.logger.warn 'davinci处理异常'
      raise error
    end

  end


  def create_back_image
    DavinciRubyClientSDK::Setting.app_key        = 'memeing'
    DavinciRubyClientSDK::Setting.app_secret     = 'xE7xkJhvy7cHxuI'
    DavinciRubyClientSDK::Setting.server_address = 'http://davinci.memeing.cn'

    blueprints = Array.new

    # 背面
    pic_b_blueprint = DavinciRubyClientSDK::Blueprint::new('pic_b')

    pic_b_blueprint.canvas do |option|
      option.add_canvas_option :width, 1500
      option.add_canvas_option :height, 1000
    end

    # 邮编
    pic_b_blueprint.add_layer 1 do |layer|
      layer.technique = :write_text
      layer.add_inspiration :size, '700'
      layer.add_inspiration :font, 'kaiti'
      layer.add_inspiration :font_size, 65
      layer.add_inspiration :kerning, 67.8
      layer.add_inspiration :font_x, 164
      layer.add_inspiration :font_y, 119
      layer.add_inspiration :text, self.receiver_post_no
    end

    # 祝福语
    pic_b_blueprint.add_layer 2 do |layer|
      layer.technique = :write_text
      layer.add_inspiration :size, '600'
      layer.add_inspiration :font, 'kaiti'
      layer.add_inspiration :font_size, 40
      layer.add_inspiration :font_x, 121
      layer.add_inspiration :font_y, 250
      layer.add_inspiration :text, self.blessings.gsub("'", "＇")
    end

    # 收件人地址
    pic_b_blueprint.add_layer 3 do |layer|
      layer.technique = :write_text
      layer.add_inspiration :size, '580'
      layer.add_inspiration :font, 'kaiti'
      layer.add_inspiration :font_size, 30
      layer.add_inspiration :font_x, 830
      layer.add_inspiration :font_y, 500
      layer.add_inspiration :text, "#{self.receiver_province}#{self.receiver_city}#{self.receiver_county}#{self.receiver_address}".gsub("'", "＇")
    end

    # 收件人姓名
    pic_b_blueprint.add_layer 4 do |layer|
      layer.technique = :write_text
      layer.add_inspiration :size, '400'
      layer.add_inspiration :font, 'kaiti'
      layer.add_inspiration :font_size, 50
      layer.add_inspiration :font_x, 1006
      layer.add_inspiration :font_y, 605
      layer.add_inspiration :text, self.receiver.gsub("'", "＇")
    end

    # 寄件人姓名
    pic_b_blueprint.add_layer 5 do |layer|
      layer.technique = :write_text
      layer.add_inspiration :size, '300'
      layer.add_inspiration :font, 'kaiti'
      layer.add_inspiration :font_size, 30
      layer.add_inspiration :font_x, 1204
      layer.add_inspiration :font_y, 827
      layer.add_inspiration :text, self.sender.gsub("'", "＇")
    end

    # 背面附图
    back_logo = self.qr_url

    if back_logo.present?
      pic_b_blueprint.add_layer 6 do |layer|
        layer.technique = :draw_image
        layer.add_inspiration :image_url, back_logo
        layer.add_inspiration :position_x, 100
        layer.add_inspiration :position_y, 150
        layer.add_inspiration :gravity, 'SouthWest'
      end
    end

    pic_b_blueprint.mount do |option|
      option.add_mount_option :ext, 'jpg'
    end

    blueprints << pic_b_blueprint.to_blueprint

    # 同步处理
    api = DavinciRubyClientSDK::API.new
    error, result = api.draw(self.osn, blueprints.to_json).call

    if error.nil?
      result = JSON.parse result
      result['results'][0]['url']
    else
      p 'davinci处理异常'
      p error
    end

  rescue => err
    p '异步线程异常'
    p err
  end

  def self.osn_generate
    [*'A'..'Z'].sample(4).join + rand(100000000000..999999999999).to_s
  end

  def self.wx_image_download(order)
    if order.media_id.present?
      account = Account.first
      $client = WeixinAuthorize::Client.new(account.app_id, account.app_secret)
      file_name =  $client.download_media_url(order.media_id)
      local_file = "/tmp/"+order.media_id+'.png'
      open(local_file, 'wb') do |file|
        file << open(file_name).read
      end
      # 向OSS上传文件
      config = {
          :aliyun_access_id  => Setting.oss.key,
          :aliyun_access_key => Setting.oss.secret,
          :aliyun_bucket     => Setting.oss.upload_bucket,
          :aliyun_internal   => Rails.env == 'production'
      }

      oss = ::OSS::Connection.new(config)
      url = oss.put(SecureRandom.uuid, File.read(local_file), :content_type => 'image/jpg')
      return url
    end
    nil
  end

  def self.wx_voice_download(order)
    account = Account.first
    $client = WeixinAuthorize::Client.new(account.app_id, account.app_secret)
    file_name =  $client.download_media_url(order.voice_media_id)
    local_file = "/tmp/"+order.voice_media_id
    open(local_file, 'wb') do |file|
      file << open(file_name).read
    end
    # 转码为mp3
    begin
      `ffmpeg -i #{local_file} #{local_file}.mp3`
    rescue
      nil
    end

    # 向OSS上传文件
    config = {
        :aliyun_access_id  => Setting.oss.key,
        :aliyun_access_key => Setting.oss.secret,
        :aliyun_bucket     => Setting.oss.upload_bucket,
        :aliyun_internal   => Rails.env == 'production'
    }

    oss = ::OSS::Connection.new(config)
    url = oss.put("#{SecureRandom.uuid}.mp3", File.read("#{local_file}.mp3"), :content_type => 'audio/mp3')

    # 生成并上传二维码文件
    qr = RQRCode::QRCode.new("http://zhang-yida.con:3000/wap/#{order.osn}", :size => 3, :level => :l)
    png = qr.to_img
    qr_blob = png.resize(200,200).to_blob

    oss = ::OSS::Connection.new(config)
    qr_url = oss.put(SecureRandom.uuid, qr_blob, :content_type => 'image/png')

    return url, qr_url
  end
end
