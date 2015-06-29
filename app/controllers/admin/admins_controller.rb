class Admin::AdminsController < Admin::BaseController
  before_filter :find_admin, only: [:edit,:update,:destroy]

  def index
    @admins = Admin.paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @admin = Admin.new

  end

  def create
    @admin = Admin.new(parmas[:admin])
    if @admin.save
      redirect_to admin_admins_path,:notice => '创建成功'
    else
      render :new
    end

  end

  def edit

  end

  def update
    @admin.update_attributes params[:admin]
    if @admin.save
      redirect_to admin_admins_path,:notice => '修改成功'
    else
      render :edit
    end
  end

  def destroy
    if Admin.count > 1
      @admin.destroy
      redirect_to admin_admins_path,:notice => '删除成功'
    else
      redirect_to admin_admins_path,:notice => '已经是最后一个了，无法删除'
    end

  end

  private
  def find_admin
    @admin = Admin.find params[:id]
  end

end
