class ProjectsController < ApplicationController

  def new
  end

  def show
    @project = Project.find(params[:id])
  end

  def create
    project_form = ProjectForm.new(project_form_params)

    if @project = project_form.submit
      redirect_to @project
    else
      flash[project_form.message_level] = project_form.message
      redirect_to project_form.redirect_to
    end
  end

  def update
    @project = Project.find(params[:id])

    @project_updater = ProjectUpdater.new(@project)

    respond_to do |format|
      if @project_updater.call(project_update_op, project_update_args)
        format.json do
          render status: :ok, json: {}
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