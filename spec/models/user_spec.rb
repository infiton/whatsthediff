describe User do
	subject(:user) { FactoryGirl.build(:user) }
	describe '#valid?' do
		context "is invalid without an email" do
			before { user.email = nil }
			it { expect(user).to_not be_valid }
		end

		context "is invalid with bad email address" do
			bad_emails = ["abcdefgf", "ade2@saf", "@sfa.com"]
			bad_emails.each do |email|
				before { user.email = email }
				it { expect(user).to_not be_valid }
			end
		end

		context "is valid with good email address" do
			good_emails = ["a@a.com", "test@example.co.nz", "hello@gmail.com"]
			good_emails.each do |email|
				before { user.email = email }
				it { expect(user).to_not be_valid }
			end
		end
	end
end