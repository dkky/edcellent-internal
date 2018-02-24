class Admin::UsersController < ApplicationController
  before_action :check_admin_access, except: [:select2_list_student]
  before_action :check_access, only: [:select2_list_student]
  respond_to :html, :json

  def new
    @user = User.new
    render layout: 'admin'
  end

  def create
    if user_params["user_access"] == "student"
      @user = User.new(user_params)
      @user.password = "bangbangda123456"
      # if group_params[:groups].is_i?
      #   # if it is a number, that means it exists in the database already
      #   group_id = group_params[:groups]
      # else
      #   # if not, add a new one in the group database
      #   group = Group.create(name: group_params[:groups])
      #   group_id = group.id
      # end
      # @user.group_ids = group_id  
      if @user.save
        @user.create_profile
        redirect_to edit_admin_profile_path(id: @user.profile.id)
      else
        @user = User.new
        render 'new'
        # add error message if failed
      end
    else
      @user = User.new(user_params)
      @user.password = "123456"
      if @user.save
        redirect_to root_path     
      else
        render 'new'
      end
    end
  end

  def index
    @filterrific = initialize_filterrific(
      User,
      params[:filterrific],
      select_options: {
        with_user_access: User.options_for_select_user_access,
        with_year_level: User.options_for_year_level
      },
    ) or return
    @users = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    render layout: 'admin'
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(user_params)
    if @user.save
      if @user.student?
        @profile = @user.build_profile
        redirect_to edit_admin_profile_path(@profile)
      else
        redirect_to @user
      end
    else 
      render 'edit'
    end
  end

  def select2_list_student
    if current_user.admin?
      @users = User.student
      render json: @users
    elsif current_user.tutor?
      @users = Group.tagged_with(current_user.name).map {|g| g.users }.flatten
      render json: @users
    end
  end

  private

  def user_params
    if params[:user][:user_access] == "student"
      params.require(:user).permit(:english_name, :first_name,:last_name, :school, :year_level, :user_access, :wechat_account, :phone_number, :email)
    else
      params.require(:user).permit(:english_name, :first_name,:last_name,:name, :user_access, :wechat_account, :phone_number, :email, :user_type)
    end
  end

  def group_params
    hash = {}
    hash[:groups] = params[:groups][0]
    hash
  end
end
