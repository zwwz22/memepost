class BackImageWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 10
  def perform(order_id)
    order = Order.find order_id
    order.successful
  end
end