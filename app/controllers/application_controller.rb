class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :require_login

  helper_method :admin?

  def require_admin
    unless admin?
      flash[:error] = "Whoops, that's an admin-only action."
      redirect_to root_path
    end
  end

  def admin?
    logged_in? && current_user.has_role?(:admin)
  end

end
