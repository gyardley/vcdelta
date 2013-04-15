class SessionsController < ApplicationController

  skip_before_filter :require_login, :except => [:destroy]

  def new
  end

  def create
    if user = login(params[:session][:email], params[:session][:password])
      redirect_back_or_to root_url, :notice => "Logged in!"
    else
      flash.now.alert = "Sorry - your email or password was incorrect."
      render 'sessions/new'
    end
  end

  def destroy
    logout
    redirect_to root_url, :notice => "Logged out!"
  end

end