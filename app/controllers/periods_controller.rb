class PeriodsController < ApplicationController
  before_action :set_period, only: [:show, :edit, :update, :destroy]
  before_action :check_access, only: [:index, :show, :edit, :update, :destroy, :calendar, :search]


  def new
    @period = Period.new
  end

  def search
    if current_user.admin?
      @periods = Period.all
    elsif current_user.tutor?
      @periods = current_user.periods
    elsif current_user.student?
      @periods = current_user.group.periods
    end

    if current_user.admin?
      @filterrific = initialize_filterrific(
        Period,
        params[:filterrific],
        select_options: {
          with_different_status: Period.options_for_different_status,
          with_different_group: Period.options_for_different_group(User.find(7))
        },
      ) or return
      @periods = @filterrific.find.page(params[:page])
    else
      @filterrific = initialize_filterrific(
        Period.where(tutor_id: current_user.id),
        params[:filterrific],
        select_options: {
          with_different_status: Period.options_for_different_status,
          with_different_group: Period.options_for_different_group(current_user)
        },
        default_filter_params: {

        },
      ) or return
      @periods = @filterrific.find.page(params[:page])
    end

    respond_to do |format|
      format.html 
      format.js 
    end
  end

  def index
    if current_user.admin?
      @periods = Period.all
    elsif current_user.tutor?
      @periods = current_user.periods
    elsif current_user.student?
      @periods = current_user.group.periods
    end
  end

  def calendar
    if current_user.admin?
      @periods = Period.all
    elsif current_user.tutor?
      @periods = current_user.periods
    elsif current_user.student?
      @periods = current_user.group.periods
    end
  end

  def create
    period = Period.new(periods_params)
    period.group_id = params[:groups][0]
    if period.save
      redirect_to period
    else
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
    @period = Period.destroy(params[:id])
    respond_to do |f|
      f.html { redirect_to root_path }
      f.js
    end
  end

  def duplicate
    @source = Period.find(params[:format])
    @period = @source.dup
    flash.now[:notice] = "This is a duplicate. Please update the info and save"
    render 'new'
  end

  def change_status
    @period = Period.find(params[:id])
    if @period.incomplete?
      @period.update(period_status: 0)
    elsif @period.done?
      @period.update(period_status: 1)  
    end
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js { render "change_status.js.erb" }
    end
  end

  private

  def periods_params
    params.require(:period).permit(:start_time, :end_time,:subject, :description, :note, :tutor_id, :period_status)
  end

  def check_access
    redirect_to '/sign_in' unless current_user
  end

  def set_period
    @period = Period.find(params[:id])
  end
end
