class Admin::ProfilesController < ApplicationController
  def new
    @user = User.find(params[:user_id])
    @profile = Profile.new
  end

  def create
    byebug
    @profile = Profile.new(strong_params)
    if @profile.save
      puts "yeah"
    else
      puts "no.."
    end
  end

  def strong_params
    params.require(:profile).permit(:text_response, :comparative_1, :comparative_2, :user_id)
  end
end
