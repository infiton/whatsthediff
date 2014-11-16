class ProjectsController < ApplicationController
  def new
  end

  def create

    @user = User.where(email: params[:user][:email]).first
    @user = @user ? @user.collect_from(user_params) : create_user

    if @user.save == false
      flash[:notice] = @user.errors.full_messages.to_sentence
      redirect_to :back and return
    end

    @project = @user.projects.build()

    if @user.save && @project.save
      flash[:notice] = "Project Successfully Created"
      redirect_to project_url(@project)
    else
      flash[:notice] = @project.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def show
    @project = Project.find(params[:id]).decorate
  end

  def upload_source_data
    @project = Project.find(params[:id])

    if @project.upload_source! :source_uploaded, params[:data]
      flash[:notice] = "The Source Data has been uploaded"
    else
      flash[:notice] = "There was an error uploading the data"
    end

    respond_to do |format|
      format.json { render :json => {:reload => project_url(@project) } }
    end
  end

  def add_target_user
    @project = Project.find(params[:id])
    @target_user = User.where(email: params[:project][:user][:email]).first
    @target_user ||= create_user

    if @target_user.save
      @project.add_target_user! :target_user_added, @target_user
      flash[:notice] = "An Email request has been sent to #{@target_user.email}"
      redirect_to project_url(@project)
    else
      flash[:notice] = @target_user.errors.full_messages.to_sentence
      redirect_to :back and return
    end
  end

  def upload_target_data
    @project = Project.find(params[:id])

    if @project.upload_target! :data_uploaded, params[:data]
      flash[:notice] = "The Target Data has been uploaded"
    else
      flash[:notice] = "There was error uploading the data"
    end

    respond_to do |format|
      format.json { render :json => {:reload => project_url(@project) } }
    end
  end

  def calculate_difference
    @project = DifferenceCalculator.new( Project.find(params[:id]) ).calculate_difference

    if @project
      @project.complete!
      @project = @project.decorate
      render :partial => "project_results"
    else
      render :partial => "error_processing_results"
    end
  end

  def download
    @project = Project.find(params[:id])

    respond_to do |format|
      format.csv { send_data @project.project_data.to_csv(params[:list]) }
      format.xls { send_data @project.project_data.to_csv(params[:list],col_sep: "\t") }
    end
  end

  protected

    def create_user
      @user = User.new(user_params)
    end

    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :company)
    end
end
