class AdminController < ApplicationController
  def all_users
  	@users = User.all
  end

  
  def edit_user
  	@user = User.find(params[:id])
  	@user.update(role: params[:role])
  	redirect_back(fallback_location: root_path)


  end

  def show_user
  	@user = User.find(params[:id])
  end
end
