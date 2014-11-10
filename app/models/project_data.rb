class ProjectData
	include Mongoid::Document
	include Mongoid::Timestamps

	field :project_id, type: Integer
	field :source_list, type: Array
	field :target_list, type: Array

	def project
		Project.find(self.project_id)
	end
end