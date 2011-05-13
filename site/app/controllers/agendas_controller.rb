class AgendasController < ApplicationController

  hobo_model_controller

  auto_actions :all

  def index
    hobo_index Agenda.state_is(:old)
  end
end
