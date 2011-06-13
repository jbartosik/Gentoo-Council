class FrontController < ApplicationController

  hobo_controller

  def index; end

  def summary
    if !current_user.administrator?
      redirect_to user_login_path
    end
  end

  def search
    query = params[:query]
    if query
      site_search(query)
    end
  end

end
