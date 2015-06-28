module ApplicationHelper


  def created_at(date)
    date.strftime('%Y-%m-%d')
  end

  def active(controller,action=nil)
    params[:controller].scan(controller).present? ? 'active':''
  end
end
