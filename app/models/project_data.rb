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

	validates_presence_of :project_id
	
	def project
		Project.find(self.project_id)
	end

	def to_csv(list, options = {})

		CSV.generate(options) do |csv|
			out = self.send(list.to_sym)
			if out.first.is_a? Array
				csv << (1..out.first.size).map{|x| "unique id #{x}"}
				out.each { |row| csv << row }
			else
				csv << ["unique id"]
				out.each {|x| csv << [x] }
			end
		end
	end

	def project_counts
		{
			source_dupes: self.source_dupes ? self.source_dupes.count : 0,
			source_uniq: self.source_uniq ? self.source_uniq.count : 0,
			target_dupes: self.target_dupes ? self.target_dupes.count : 0,
			target_uniq: self.target_uniq ? self.target_uniq.count : 0,
			source_target_union: self.source_target_union ? self.source_target_union.count : 0
		}
	end
end