class ProjectUpdater

  def initialize(project)
    @project = project
  end

  def call(op,args)
    unless respond_to?(op, true)
      @errors = ["#{op} is an unknown operation for updating a project"]
      return false
    end

    send(op,args)
  end

  def errors
    @errors
  end

  private

    def save_or_report
      if @project.save
        @project
      else
        @errors = @project.errors.full_messages
        false
      end
    end

    def configure(args={})
      if @project.configure(args)
        save_or_report
      else
        @errors = ["Could not configure project"]
        false
      end
    end

    def load_data_chunk(args={})
      loader = ProjectRowLoader.new(@project, args[:data_type], args[:chunk])

      unless loader.valid?
        @errors = loader.errors.full_messages
        return false
      end

      if loader.call(args[:is_last_chunk])
        @project
      else
        @errors = ["Could not load data chunk"]
        false
      end
    end

    def select_target(args={})
      target = User.find_or_create_by(email: args[:target_email]) 
      if target.valid? && @project.select_target(target)
        binding.pry
        save_or_report
      else
        @errors = target.errors.full_messages
        false
      end
    end
        
end