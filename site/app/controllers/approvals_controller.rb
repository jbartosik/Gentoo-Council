class ApprovalsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :index]

end
