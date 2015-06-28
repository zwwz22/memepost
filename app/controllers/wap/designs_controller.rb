class Wap::DesignsController < Wap::ApplicationController
  #before_filter :wx_oauth,:except => [:get_templates,:show]

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

    order_media_id = @order.voice_media_id

    @order.voice_local_id = params[:voice_local_id]
    @order.voice_media_id = params[:voice_media_id]

    ##录音还未上传
    #if @order.voice_url.blank? &&  params[:voice_media_id].present?
    #  #下载录音
    #  voice_url,qr_url = Order.wx_voice_download(@order)
    #  @order.voice_url = voice_url
    #  @order.qr_url    = qr_url
    #  @order.save
    #end
    ##新传入的录音
    #if params[:voice_media_id].present? && order_media_id.present? && order_media_id != params[:voice_media_id]
    #  #重新下载录音
    #  voice_url,qr_url = Order.wx_voice_download(@order)
    #  @order.voice_url = voice_url
    #  @order.qr_url    = qr_url
    #end

    @order.save

    @order.gen_blessings

    render :json => {:status => true,:redirect_url => success_wap_designs_path(:osn => @order.osn)}
  end

  def success
    @order = Order.find_by_osn params[:osn]

    ##测试订单
    BackImageWorker.perform_async(@order.id)
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
