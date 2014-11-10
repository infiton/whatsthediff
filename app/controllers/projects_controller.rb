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

    @project = @user.projects.build(state: :new)

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

    @user = @project.user
  end

  def add_target_user
    @project = Project.find(params[:id])
    @target_user = User.where(email: params[:user][:email]).first
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

  def upload_source_data
    @project = Project.find(params[:id])
    @project_data = ProjectData.new(project_id: @project.id)

    @project_data.source_list = params[:data].map {|idx,row| row}
    #this will create another record in MongoDB... may want that behaviour, may not
    if @project_data.save
      flash[:notice] = "The Source Data has been uploaded"
      @project.source_uploaded
    else
      flash[:notice] = "Something went wrong uploading the source data"
    end

    respond_to do |format|
      format.json { render :json => {:reload => project_url(@project) } }
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
