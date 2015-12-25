class ProjectResultsController < ApplicationController
  def show
    @project_result = ProjectResult.find(params[:id])

    if @project_result && @project_result.file_exists?
      send_file @project_result.file_path, type: "text/csv; charset=utf-8", x_sendfile: true
    else
      flash[:danger] = ts('fail')
      redirect_to :back and return
    end
  end
end