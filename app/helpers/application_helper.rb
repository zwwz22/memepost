module ApplicationHelper


  def created_at(date,seconds=false)
    if seconds
      date.strftime('%Y-%m-%d %H:%S:%M')

    else
      date.strftime('%Y-%m-%d')

    end
  end

  def active(controller,action=nil)
    params[:controller].scan(controller).present? ? 'active':''
  end
end
