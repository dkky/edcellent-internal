class Admin::GroupsController < ApplicationController
  respond_to :html, :json
  layout :determine_layout, only: [:index]


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
    @group.tutor_list = @tutor.name
    if @group.save
      respond_to do |format|
        format.html 
        format.js { flash[:notice] = "You have successfully selected " + @group.tutor_list.first }
      end
    else
      render 'index', flash[:error] = "Failure to select your tutor"
    end
  end

  private

  def determine_layout
    current_user.admin? ? "admin" : "application"
  end
end
