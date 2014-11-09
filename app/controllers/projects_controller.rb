class ProjectsController < ApplicationController
  def new

  end

  def create

    @user = User.where(email: params[:project][:user][:email]).first
    @user ||= create_user

    if @user.save == false
      flash[:notice] = "User could not be created"
      redirect_to :back and return
    end

    @project = Project.new(
                 base_user_id: @user.id)

    if @user.save && @project.save
      flash[:notice] = "Project Successfully Created"
      redirect_to project_url(@project)

      #send email with link to  "/projects/:project_id"
    else
      flash[:notice] = "Project Could Not be created"
      redirect_to :back
    end
  end

  def show
    @project = Project.find(params[:id])

    @base_user = User.find(@project.base_user_id)
  end

  def add_target_user
    @project = Project.find(params[:project][:id])
    @target_user = User.where(email: params[:project][:user][:email]).first
    @target_user ||= create_user

    if @target_user.save
      #send email to target_user with link to 'projects/:project_id'
      # redirect_to 'some congrats page or somefing'?
      flash[:notice] = "An Email request has been sent to #{@target_user.email}"
      @project.target_uploaded
      redirect_to project_url(@project)
    else
      flash[:notice] = "Email couldn't be sent"
      redirect_to :back and return
    end
  end

protected

  def create_user
    @user = User.new(
          email: params[:project][:user][:email],
          first_name: params[:project][:user][:first_name],
          last_name: params[:project][:user][:last_name],
          company: params[:project][:user][:company]
         )
  end

end
