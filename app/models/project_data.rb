class ProjectData
	include Mongoid::Document
	include Mongoid::Timestamps

	field :project_id, type: Integer
	field :source_list, type: Array
	field :target_list, type: Array
	field :source_dupes, type: Array
	field :target_dupes, type: Array
	field :source_uniq, type: Array
	field :target_uniq, type: Array
	field :source_target_union, type: Array

	def project
		Project.find(self.project_id)
	end
end