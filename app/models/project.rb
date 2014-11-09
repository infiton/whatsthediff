class Project < ActiveRecord::Base

  obfuscate_id :spin => 8675309
  belongs_to :user

  validates_presence_of :state, :in => [:new, :source_uploaded, :target_uploaded, :complete]

  def source_uploaded
    self.state = :source_uploaded
  end

  def target_uploaded
    self.state = :target_uploaded
  end

  def complete
    self.state = :complete
  end

end

