class Project < ActiveRecord::Base

  obfuscate_id :spin => 8675309
  belongs_to :user

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

