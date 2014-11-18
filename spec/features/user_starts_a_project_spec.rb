feature 'User starts a project' do
	scenario 'they see the Get Started button on the page' do
		visit root_path
		expect(find_link('Get Started')[:href]).to eq new_project_path
	end

	scenario 'they click Get Started and they go to a new project page' do
		visit root_path
		click_link('Get Started')
		expect(current_path).to eq new_project_path
	end

	scenario 'they fill out the form and start a new project as the user' do
		visit new_project_path
		fill_in 'user_email', with: 'example@valid.com'
		click_button 'Save User'
		project_id = URI.split(current_url)[5].split('/')[2]
		expect(Project.find(project_id).user.email).to eq 'example@valid.com'
	end
end