class Project < ActiveRecord::Base

  obfuscate_id :spin => 8675309
  belongs_to :user

  validates_presence_of :state, :in => [:new, :source_uploaded, :target_uploaded, :complete]
  #need to remove data_id and target_data_id from schema
  def project_data
    ProjectData.where(project_id: self.id).first
  end

  def source_uploaded
    self.state = :source_uploaded
    self.save
  end

  def target_uploaded
    self.state = :target_uploaded
    self.save
  end

  def complete
    self.state = :complete
    self.save
  end

end

