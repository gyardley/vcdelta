class PasswordResetsController < ApplicationController

  skip_before_filter :require_login

  def create
    @user = User.find_by_email(params[:reset][:email])
    @user.deliver_reset_password_instructions! if @user
    redirect_to(root_path, :notice => "We've emailed you with instructions on how to reset your password.")
  end

  def edit # the reset password form
    @user = User.load_from_reset_password_token(params[:id])
    logger.info params[:id]
    @token = params[:id]
    not_authenticated unless @user
  end

  def update

    @token = params[:reset][:token]
    @user = User.load_from_reset_password_token(params[:reset][:token])
    not_authenticated unless @user

    @user.password_confirmation = params[:reset][:password_confirmation]

    if @user.change_password!(params[:reset][:password])
      redirect_to(root_path, :notice => 'Password was successfully updated.')
    else
      render :action => "edit"
    end
  end

end