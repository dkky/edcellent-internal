class Admin::ProfilesController < ApplicationController
  before_action :check_admin_access

  def new
    @user = User.find(params[:user_id])
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(strong_params)
    @user = User.find(params[:profile][:user])
    if @profile.save
      redirect_to admin_user_path(params[:profile][:user])
    else
      render 'new'
    end
  end

  def edit
    byebug
    @profile = Profile.find(params[:id])
    @user = @profile.user
  end

  def update
    @profile = Profile.find(params[:id])
    @profile.update(strong_params)
    redirect_to admin_user_path(@profile.user)
  end

  def strong_params
    params.require(:profile).permit(:text_response, :comparative_1, :comparative_2, :user_id)
  end
end
