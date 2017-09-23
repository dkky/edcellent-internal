class Admin::ProfilesController < ApplicationController
  def new
    @user = User.find(params[:user_id])
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(strong_params)
    if @profile.save
      byebug
      redirect_to admin_user_path(params[:profile][:user_id])
    else
      render 'new'
    end
  end

  def edit
    @profile = User.find(params[:id]).profile
  end

  def strong_params
    params.require(:profile).permit(:text_response, :comparative_1, :comparative_2, :user_id)
  end
end
