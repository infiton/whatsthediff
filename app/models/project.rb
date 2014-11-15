class Project < ActiveRecord::Base
  include AASM
  obfuscate_id :spin => 8675309
  belongs_to :user
  
  def target_user
    User.where(id: self.target_user_id).first
  end

  def project_data
    ProjectData.where(project_id: self.id).first
  end

  aasm :column => :state do
    state :new, :initial => true, :after => UserMailer.new_project_email(self.user,self).deliver
    state :source_uploaded
    state :target_user_added
    state :data_uploaded
    state :completed

    event :upload_source do
      transitions :from => :new, :to => :source_uploaded
      before do |data|
        #we maybe should refactor this to a service object
        ProjectData.create( project_id: self.id, source_list: data.map {|idx,row| row} )
      end
    end

    event :add_target_user do
      transitions :from => :source_uploaded, :to => :target_user_added
      before do |target_user|
        #again add service object here
        self.target_user_id = target_user.id
        UserMailer.target_user_added_email(target_user, self.user, self).deliver
      end
    end

    event :upload_target do
      transitions :from => :target_user_added, :to => :data_uploaded
      before do |data|
        puts data
        self.project_data.update( target_list: data.map {|idx,row| row} )
      end
    end

    event :complete do
      transitions :from => :data_uploaded, :to => :completed
    end
  end


  #validates :state, inclusion: {in: ["new", "source_uploaded", "target_added", "target_uploaded", "data_uploaded", "complete"] }
  ##need to remove data_id and target_data_id from schema
  #def project_data
  #  ProjectData.where(project_id: self.id).first
  #end
#
  #def target_user
  #  User.where(id: self.target_user_id).first
  #end
#
  #def source_uploaded
  #  change_state_to "source_uploaded"
  #end
#
  #def target_added
  #  change_state_to "target_added"
  #end
#
  #def target_uploaded
  #  change_state_to "target_uploaded"
  #end
#
  #def data_uploaded
  #  change_state_to "data_uploaded"
  #end
#
  #def complete
  #  change_state_to "complete"
  #end
#
  #def complete?
  #  self.state == "complete"
  #end
#
  #def add_target_user user
  #  self.target_user_id = user.id
  #  self.target_added
  #end

  #private
#
  #  def change_state_to state
  #    self.state = state
  #    self.save
  #  end
  
end