class ProjectRow < ActiveRecord::Base
  enum data_type: { source: 0, target: 1 }
  belongs_to :project
end