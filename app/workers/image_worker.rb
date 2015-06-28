class ImageWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 10
  def perform(order_id)
    order = Order.find order_id
      url = Order.wx_image_download(order)
      order.image_url = url
      order.save

    p order.state

      #每次调用重新生成正面图片
      order.back
      ####

    p order.state
      order.gen_image

    p order.state
  end
end