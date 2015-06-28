class Admin::CategoriesController < Admin::ApplicationController
  def index
    @categories = Category.all

  end

  def new
    @category = Category.new

  end

  def create
    @category = Category.create params[:category]

    if @category.save
      redirect_to admin_categories_path,:notice => '新建成功'
    else
      render :new
    end

  end

  def edit
    @category = Category.find params[:id]
  end

  def update
    @category = Category.find(params[:id]).update_attributes params[:category]
    if @category
      redirect_to admin_categories_path, :notice => '修改成功'
    else
      render :edit
    end

  end

end
