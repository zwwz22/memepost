class Admin::QuestionsController < Admin::BaseController
  before_filter :find_question, only: [:edit,:update]

  def index
    @questions = Question.paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @question = Question.new
  end

  def create
    @question = Question.create params[:question]
    if @question.save
      redirect_to admin_questions_path,:notice =>'创建成功'
    else
      render :new
    end
  end

  def edit
  end

  def update
    @question = @question.update_attributes params[:question]
    if @question
      redirect_to admin_questions_path,:notice =>'修改成功'
    else
      render :edit
    end
  end

  private
  def find_question
    @question = Question.find(params[:id])
  end


end
