class PeriodsController < ApplicationController
  before_action :set_period, only: [:show, :edit, :update, :destroy]


  def new
    @period = Period.new
  end

  def index
    @periods = Period.all
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_period
    @period = Period.find(params[:id])
  end
end
