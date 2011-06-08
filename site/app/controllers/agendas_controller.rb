class AgendasController < ApplicationController

  hobo_model_controller

  before_filter :authenticate_bot, :only => :results
  auto_actions :all

  def index
    hobo_index Agenda.state_is(:old)
  end

  def current_items
    render :json => Agenda.current.voting_array
  end

  def results
    data = JSON.parse(request.env["rack.input"].read)
    Agenda.process_results data
    Participation.mark_participations data
  end

  def reminders
    render :json => Agenda.irc_reminders
  end

  private
    def authenticate_bot
      authenticate_or_request_with_http_basic do |user_name, password|
        user_name == CustomConfig['Bot']['user'] && password == CustomConfig['Bot']['password']
      end
    end
end
