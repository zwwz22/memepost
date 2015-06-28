class Admin::DashboardController < Admin::ApplicationController
  def index
    @users  = User.all.count
    @total  = Order.all.count
    @messages = Order.all.count

    @orders =  Order.find_by_sql("SELECT COUNT(*) AS count, DATE_FORMAT(created_at,'%Y-%m-%d') AS day FROM `orders` WHERE created_at >= '#{(Time.now-7.days).beginning_of_day}' and created_at <= '#{Time.now.end_of_day}' GROUP BY day")

  end

end
