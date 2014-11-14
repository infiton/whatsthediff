class Project < ActiveRecord::Base

  obfuscate_id :spin => 8675309
  belongs_to :user

  validates :state, inclusion: {in: ["new", "source_uploaded", "target_added", "target_uploaded", "data_uploaded", "complete"] }
  #need to remove data_id and target_data_id from schema
  def project_data
    ProjectData.where(project_id: self.id).first
  end

  def target_user
    User.where(id: self.target_user_id).first
  end

  def source_uploaded
    change_state_to "source_uploaded"
  end

  def target_added
    change_state_to "target_added"
  end

  def target_uploaded
    change_state_to "target_uploaded"
  end

  def data_uploaded
    change_state_to "data_uploaded"
  end

  def complete
    change_state_to "complete"
  end

  def complete?
    self.state == "complete"
  end

  def add_target_user user
    self.target_user_id = user.id
    self.target_added
  end

  private

    def change_state_to state
      self.state = state
      self.save
    end
  
end