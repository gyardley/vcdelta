class LocationsController < ApplicationController

  skip_before_filter :require_login, :only => [:index]

  before_filter :require_admin, :except => [:index]

  def index
    @locations = Location.all
  end

  def new
    @location = Location.new
  end

  def create

    location_params = params.require(:location).permit(
      :name,
      :url
    )

    @location = Location.new(location_params)
    if @location.save
      redirect_to locations_url, :notice => "Great, we've added that location."
    else
      render :new
    end

  end

  def destroy

    @location = Location.find(params[:id])
    @location.destroy
    redirect_to locations_url

  end

end