class UserMailer < ActionMailer::Base
  default from: "no-reply@whatsthediff.ca"

  def new_project_email(user,project)
  	@user = user
  	@project = project
  	mail(to: @user.email, subject: "You started a new project")
  end

  def target_user_added_email(target_user,user,project)
  	@target_user = target_user
  	@user = user
  	@project = project
  	mail(to: @target_user.email, subject: "Someone has shared a project with you")
  end
end
