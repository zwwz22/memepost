class Admin::TemplatesController < Admin::ApplicationController
  before_filter :current_template, :only => [:edit,:update,:destroy]

  def index
    @templates = Template.all
  end

  def new
    @template = Template.new
  end

  def create
    if params[:template][:up_file].present?
      params[:template][:image_url],_ = upload_file params[:template][:up_file]
      params[:template].delete(:up_file)
    end
    @template = Template.create(params[:template])
      if @template.save
        redirect_to admin_templates_path,:notice => '创建成功'
      else
        render :new
      end
  end

  def edit

  end

  def update
    @template.update_attributes params[:template]
    if @template.save
      redirect_to admin_templates_path, :notice => '修改成功'
    else
      render :edit
    end

  end

  def destroy
    if @template.destroy
      redirect_to admin_templates_path, :notice => '删除成功'
    end
  end

  private

  def current_template
    @template = Template.find params[:id]
  end


end
