class ProjectsController < ApplicationController

  def new
  end

  def show
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

  def source

    respond_to do |format|
      format.json do
        render status: :ok, json: {}
      end
    end

  end

  private
    def project_form_params
      params
        .require(:project_form)
        .permit(ProjectForm.permitted_attributes)
    end
end