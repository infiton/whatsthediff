module ProjectsHelper
	def get_csv project, list
		link_to "get csv", download_project_path(project, :list => list, :format => "csv")
	end

	def get_xls project, list
		link_to "get xls", download_project_path(project, :list => list, :format => "xls")
	end
end
