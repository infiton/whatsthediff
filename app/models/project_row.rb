class ProjectRow < ActiveRecord::Base
  DATA_TYPES = ["source", "target"]
  belongs_to :project

  #I explicitly do not want to check for the presence of project
  #in the database, since when generating mass inserts I do not want
  #looped database calls. We settle here for presence of a project_id,
  #if the project doesn't exist, we will have tasks to clean up orphaned data
  validates :project_id, presence: true
  validates :data_type, inclusion: { :in => DATA_TYPES }
  validates :uid, presence: true
  validates :digest, presence: true


  DATA_TYPES.each do |data_type|
    scope data_type, -> { where(data_type: data_type)} 
  end
  #factory method to aid in mass inserts
  #want to create associations to a project
  #without adding to the active record association cache
  def self.build_from!(project, args={})
    project_row = new(args)
    project_row.project_id = project.id

    return project_row if project_row.validate!
  end

  def self.build_from(project, args={})
    begin
      build_from!(project, args)
    rescue ActiveRecord::RecordInvalid
      nil
    end
  end
end