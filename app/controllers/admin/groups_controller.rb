class Admin::GroupsController < ApplicationController
  before_action :check_admin_access
  before_action :check_admin_access, except: [:select2_list_groups]


  respond_to :html, :json
  layout :determine_layout, only: [:index, :edit]

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

  def edit
    @group = Group.find(params[:id])
    # @tutors = @group.tutors.pluck(:id).map { |i| i.to_s }.to_json
    @tutor_names = @group.tutors.pluck(:name)
    @ids = @tutor_names.map {|tutor_name| User.select {|u| u.eng_version_name == tutor_name}.first.id}
    @tutors = @ids.map {|i| i.to_s}.to_json
    # @tutors = User.where(id: @group.tutors.pluck(:name).map {|name| name.split(' ' )[0]}).pluck(:id).map {|i| i.to_s}.to_json
  end

  def show
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    @tutor = User.find(params[:tutors]).map {|u|u.eng_version_name}
    @group.tutor_list = @tutor
    @group.update(name: params[:group][:name])
    unless params[:group][:group_status].blank?
      @group.update(group_status: params[:group][:group_status].to_i)
    end
    # id = params[:id].scan(/\d+/).first.to_i
    # @group = Group.find(id)
    # tutor_id = params[:tutor_id].to_i
    # @tutor = User.find(tutor_id)
    # @group.tutor_list << @tutor.eng_version_name
    if @group.save
      redirect_to admin_group_path(@group)
      # respond_to do |format|
      #   format.html 
      #   format.js { flash[:notice] = "You have successfully selected " + @tutor.name }
      # end
    else
      render 'edit'
      # render 'index', flash[:error] = "Failure to select your tutor"
    end
  end

  private

  def determine_layout
    current_user.admin? || current_user.superadmin? ? "admin" : "application"
  end

  def select2_list_groups
    if params[:term][:term]
      @users = User.search_name(params[:term][:term]).where(user_access: 1)
    else
      @users = User.student
    end
  end

  def sanitize_group_params
    if !params[:groups].blank?
      params[:groups].map(&:to_i) 
    else  
      return []
    end
  end
end
