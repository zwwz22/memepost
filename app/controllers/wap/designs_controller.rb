class Wap::DesignsController < Wap::BaseController
  before_filter :wx_oauth,:except => [:get_templates,:show]

  def index
  end

  def new
    @order = Order.find_by_osn params[:osn] if params[:osn].present?
    @templates  = Template
    @account_id = Account.last.id
    @categories = Category.order('display desc').all
    if @categories
      @templates = @templates.where(:category_id => @categories.first.id )
    end
    @templates.all
  end

  def create_order
    @order = Order.find_by_osn params[:osn] if params[:osn].present?
    if @order
      @order.x = params[:x]
      @order.y = params[:y]
      @order.scale = params[:scale]
      @order.scale_card = params[:scale_card]
      @order.rotation = params[:rotation]
      @order.pos_x = params[:pos_x]
      @order.pos_y = params[:pos_y]
      @order.front_image_url = nil  #重新生成正面图
      @order.template_id = params[:template_id]
      @order.save
    else
      @order = Order.new
      @order.user_id = 1
      @order.x = params[:x]
      @order.y = params[:y]
      @order.scale = params[:scale]
      @order.scale_card = params[:scale_card]
      @order.rotation = params[:rotation]
      @order.pos_x = params[:pos_x]
      @order.pos_y = params[:pos_y]
      @order.template_id = params[:template_id]
      @order.account_id  = params[:account_id]
      @order.media_id    = params[:media_id]
      @order.local_id    = params[:local_id]
      @order.price       = 0
      @order.auto_orient = params[:auto_orient]
      begin
        @order.osn = Order.osn_generate
        @order.save
    rescue => e
      retry
    end
    end

    ##获取微信图片 并上传
    ImageWorker.perform_async(@order.id)

    render json: {:status => true,:redirect_url => write_address_wap_designs_url(:osn => @order.osn)}

  end

  def write_address
    @order = Order.find_by_osn params[:osn]
  end

  def update_address
    @order = Order.find_by_osn params[:osn]
    @order.receiver = params[:receiver]
    @order.receiver_province = params[:receiver_province]
    @order.receiver_city = params[:receiver_city]
    @order.receiver_county = params[:receiver_county]
    @order.receiver_post_no = params[:receiver_post_no]
    @order.receiver_address = params[:receiver_address]
    @order.save
    @order.gen_address
    render :json => {:status => true,:redirect_url => write_blessings_wap_designs_path(:osn => @order.osn)}
  end

  def write_blessings
    @order = Order.find_by_osn params[:osn]
  end

  def update_blessings
    @order = Order.find_by_osn params[:osn]
    @order.blessings = params[:blessings]
    @order.sender    = params[:sender]
    @order.question_id = params[:question_id]
    @order.answer      = params[:answer]

    @order.voice_local_id = params[:voice_local_id]
    @order.voice_media_id = params[:voice_media_id]

    @order.save

    @order.gen_blessings

    render :json => {:status => true,:redirect_url => success_wap_designs_path(:osn => @order.osn)}
  end

  def success
    @order = Order.find_by_osn params[:osn]

    ##测试订单
    #BackImageWorker.perform_async(@order.id)
  end

  def pay
    @order = Order.find_by_osn params[:osn]
    if @order.present?
      create_we_pay @order
    end
  end

  # 创建支付
  def create_we_pay(order)

    configs = {
        :appid  => Setting.wechat.appid,
        :mch_id => Setting.wechat.mch_id,
        :key    => Setting.wechat.key,
    }
    js_payment = ::Rwepay::JSPayment.new(configs)

    options = {
        :body => '么么印线上定制',
        :notify_url => 'http://shop.memeing.cn/online/purchase_notify',
        :out_trade_no => "#{order.osn}",
        :total_fee => order.total_fee,
        :spbill_create_ip => request.ip,
        :trade_type => 'JSAPI',
        :openid => @user.openid,
    }

    brand_json, succ, prepay_id = js_payment.get_brand_request(options)

    if succ
      {:status => true, :brand => JSON.parse(brand_json), :osn => order.osn}
    else
      begin
        Rails.logger.warn(prepay_id.body)
      rescue
        nil
      end
      {:status => false, :error_message => '微信支付创建失败，请稍后重试'}
    end
  end

  def show
    @order = Order.find_by_osn params[:id]
    if @order.blank? || @order.voice_url.blank?
      return render :text => '404'
    end
  end

  def get_templates
    templates = Template.where(:category_id => params[:category_id])
    render json: {:success => true,:templates => templates }
  end

end
