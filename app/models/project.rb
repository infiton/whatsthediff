class Project < ActiveRecord::Base

  #this relationship is necessary for nested_attributes, but not ideal
  belongs_to :user
  accepts_nested_attributes_for :user

  def source_uploaded
    self.state = "Source Uploaded"
  end

  def target_uploaded
    self.state = "Target Uploaded"
  end

  def complete
    self.state = "Complete"
  end

end

