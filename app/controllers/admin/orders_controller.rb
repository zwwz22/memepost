class Admin::OrdersController < Admin::BaseController
  def index
    @orders = Order.paginate(:page => params[:page],:per_page => 20)
  end

  def show
    @order = Order.find params[:id]
  end
end
