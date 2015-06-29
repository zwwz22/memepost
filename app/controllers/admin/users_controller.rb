class Admin::UsersController < Admin::BaseController
  def index
    @users = User.paginate(:page => params[:page],:per_page => 20)
  end

  def show
  end
end
