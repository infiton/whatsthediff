class ProjectForm
  include ActiveModel::Model

  attr_accessor :email, :first_name, :last_name, :company, :collect_info
  attr_reader :message, :message_level, :redirect_to

  validates :email, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  def initialize(attrs={})
    attrs.each do |k,v|
      send("#{k}=",v) if respond_to?("#{k}")
    end
  end

  def submit
    if user = find_user
      create_project(user)
    elsif collect_info 
      if valid?
        user = User.new(email: email, first_name: first_name, last_name: last_name, company: company)

        if user.save
          create_project(user)
        else
          @message_level = :danger
          @message = user.errors.full_messages.to_sentence
          @redirect_to = :back
          return nil
        end
      else
        @message_level = :danger
        @message = errors.full_messages.to_sentence
        @redirect_to = :back
        return nil
      end
    else
      @message_level = :info
      @message = "Looks like we haven't met before! We'll need some info to get started."
      @redirect_to = Rails.application.routes.url_helpers.new_project_path
      return nil
    end
  end

  def self.permitted_attributes
    [:email, :first_name, :last_name, :company, :collect_info]
  end

  private
    def find_user
      return nil unless email
      User.find_by(email: email)
    end

    def create_project(user)
      user.projects.create
    end

end