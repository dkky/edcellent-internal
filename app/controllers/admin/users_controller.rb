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
    byebug
    if @user.save
      if @user.student? || @user.dropout? || @user.alumni? || @user.trial?
        if @user.profile.nil?
          @user.create_profile
          @profile = @user.profile
        else
          @profile = @user.profile
        end
        redirect_to edit_admin_profile_path(@profile)
      else
        redirect_to admin_user_path(@user)
      end
    else 
      render 'edit'
    end
  end

  def select2_list_student
    if current_user.admin? || current_user.superadmin?
      if params[:term][:term]
        @users = User.search_name(params[:term][:term]).where(user_access: 1)
      else
        @users = User.student
      end
    elsif current_user.tutor?
      if params[:term] && params[:term][:term]
        user_ids = User.search_name(params[:term][:term]).where(user_access: 1).pluck(:id) & Group.tagged_with(current_user.eng_version_name).map {|g| g.users }.flatten.pluck(:id)
        @users = User.find(user_ids)
      else
        @users = Group.tagged_with(current_user.eng_version_name).map {|g| g.users }.flatten
      end
    end
    render json: @users  
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
