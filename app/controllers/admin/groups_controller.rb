class Admin::GroupsController < ApplicationController
  respond_to :html, :json
 
  def index
    @groups = Group.all
    render json: @groups
  end
end
