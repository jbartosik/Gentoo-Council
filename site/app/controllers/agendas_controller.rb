class AgendasController < ApplicationController

  hobo_model_controller

  auto_actions :all

  def index
    hobo_index Agenda.state_is(:old)
  end

  def current_items
    render :json => Agenda.current.voting_array
  end
end
