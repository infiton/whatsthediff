class ProjectsController < ApplicationController

  def new
    @project_form = ProjectForm.new
  end

  def show
    @project = Project.find_by_slug(params[:id])
    @project.decorate
    respond_to do |format|
      if @project
        @project = @project.decorate
        format.html #show.html.erb
        format.json do
          render status: :ok, json: @project.to_hash
        end
      else
        format.html do
          flash[:danger] = "Could not find that project"
          redirect_to :back and return
        end

        format.json do
          render status: 404, json: { errors: ["project not found"] }
        end
      end
    end
  end

  def create
    @project_form = ProjectForm.new(project_form_params)

    if @project = @project_form.submit
      redirect_to @project
    else
      flash.now[@project_form.message_level] = @project_form.message
      render "new"
    end
  end

  def update
    @project = Project.find_by_slug(params[:id])

    @project_updater = ProjectUpdater.new(@project)

    respond_to do |format|
      if @project_updater.call(project_update_op, project_update_args)
        format.json do
          render status: :ok, json: @project_updater.return_data
        end
      else
        format.json do
          render status: :unprocessable_entity, json: {errors: @project_updater.errors}
        end
      end
    end
  end

  private
    def project_form_params
      params
        .require(:project_form)
        .permit(ProjectForm.permitted_attributes)
    end

    def project_update_op
      params[:op]
    end

    def project_update_args
      params[:args]
    end
end