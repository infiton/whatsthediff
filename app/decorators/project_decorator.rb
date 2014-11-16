class ProjectDecorator < Draper::Decorator
	delegate_all

	#formats the user name for the project
	def user_name
		object.user.first_name? ? object.user.first_name : object.user.email
	end

	def target_user_name
		if object.target_user
			object.target_user.first_name? ? object.target_user.first_name : object.target_user.email
		else
			nil
		end
	end
	#gets counts for display in results
	def counts
		object.project_data ? object.project_data.project_counts : nil
	end

	def headers
		object.project_data and object.project_data.source_list ? object.project_data.source_list.first.keys.select{|k| k!="uuid"} : nil
	end
end