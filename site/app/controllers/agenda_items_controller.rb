class AgendaItemsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  before_filter :login, :except => :show

  protected
    def login
      redirect_to user_login_path unless current_user.signed_up?
    end
end
