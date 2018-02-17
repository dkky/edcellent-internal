class Admin::GroupsController < ApplicationController
  before_action :check_admin_access

  respond_to :html, :json
  layout :determine_layout, only: [:index]

  def new
    @group =  Group.new
  end

  def create
    if existing_group = Group.joins(:users).where('users.id' => sanitize_group_params).select {|g| g.user_ids.sort == sanitize_group_params.sort}.first
      @group =  Group.new
      respond_to do |format|
        format.html { 
          flash.now[:error] = "This is a duplicate of an existing group..."
          render :new
        }
      end
    else
      new_group = Group.new
      new_group.user_ids = sanitize_group_params
      user = User.find(*sanitize_group_params)
      if user.class == Array
        new_group.name = User.find(*sanitize_group_params).pluck(:english_name, :last_name).map {|arr| arr.join(" ") }.join(", ")
      else 
        new_group.name = user.english_name + ' ' + user.last_name
      end
      if new_group.save
        flash[:success] = "Good job! A new group has been created!"
        redirect_to admin_groups_path
      else
        @group =  Group.new
        respond_to do |format|
          format.html { 
            flash.now[:error] = "You have failed to create a new group..."
            render :new
          }
        end
      end
    end
  end


  def index
    @groups = Group.all

    @filterrific = initialize_filterrific(
        Group,
        params[:filterrific],
        select_options: {
          with_different_tutor: Group.options_for_tutor,
          # with_different_grouping: Group.options_for_grouping 
        },
      ) or return
      @groups = @filterrific.find.page(params[:page])

      
    respond_to do |format|
      format.html 
      format.js 
    end
  end

  def update
    id = params[:id].scan(/\d+/).first.to_i
    tutor_id = params[:tutor_id].to_i
    @group = Group.find(id)
    @tutor = User.find(tutor_id)
    @group.tutor_list << @tutor.name
    if @group.save
      respond_to do |format|
        format.html 
        format.js { flash[:notice] = "You have successfully selected " + @tutor.name }
      end
    else
      render 'index', flash[:error] = "Failure to select your tutor"
    end
  end

  private

  def determine_layout
    current_user.admin? ? "admin" : "application"
  end

  def sanitize_group_params
    if !params[:groups].blank?
      params[:groups].map(&:to_i) 
    else  
      return []
    end
  end
end
