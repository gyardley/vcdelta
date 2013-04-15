class UsersController < ApplicationController

  skip_before_filter :require_login, :only => [:index, :new, :create, :activate]

  def new
    @user = User.new
  end

  def create

    user_params = params.require(:user).permit(
      :email,
      :password,
      :password_confirmation
    )

    @user = User.new(user_params)
    if @user.save
      redirect_to root_url, :notice => "Great, we've created your account. To activate it, please check your email and click on the confirmation link we've sent."
    else
      render :new
    end
  end

  def activate
    if (@user = User.load_from_activation_token(params[:id]))
      @user.activate!
      redirect_to(login_path, :notice => "Great, we've successfully activated your account.")
    else
      not_authenticated
    end
  end

end
