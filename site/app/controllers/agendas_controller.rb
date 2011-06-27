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
    Agenda.update_voting_options data['agenda']
    Agenda.process_results data data['votes']
    agenda = Agenda.current
    agenda.meeting_log = data['lines']
    Participation.mark_participations data
  end

  def reminders
    render :json => Agenda.irc_reminders
  end

  private
    def authenticate_bot
      botconf = CustomConfig['Bot']
      authenticate_or_request_with_http_basic do |user_name, password|
        user_name == botconf['user'] && password == botconf['password']
      end
    end
end
