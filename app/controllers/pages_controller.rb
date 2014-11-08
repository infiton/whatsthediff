class PagesController < ApplicationController
  def home
  	@user = User.all.first
  end
end
