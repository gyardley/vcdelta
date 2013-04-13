class StaticController < ApplicationController

  skip_before_filter :require_login

  def index
  end

  def about
  end

end