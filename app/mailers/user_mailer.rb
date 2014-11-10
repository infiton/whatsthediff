class UserMailer < ActionMailer::Base
  default from: "no-reply@whatsthediff.ca"

  def new_project_email(user,project)
  	@user = user
  	@project = project
  	mail(to: @user.email, subject: "You started a new project")
  end
end
