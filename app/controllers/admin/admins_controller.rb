class Admin::AdminsController < Admin::ApplicationController

  def index
    @admins = Admin.all
  end

end
