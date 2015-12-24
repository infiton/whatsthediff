class ProjectDiffJob < ActiveJob::Base
  queue_as :default

  def perform(project)
    #create the overlap csv
    ProjectResult.create_overlap_for(project)

    #create the unique csvs
    ProjectResult.create_uniques_for(project, :source)
    ProjectResult.create_uniques_for(project, :target)

    #create the duplicate csvs
    ProjectResult.create_duplicates_for(project, :source)
    ProjectResult.create_duplicates_for(project, :target)
  end
end