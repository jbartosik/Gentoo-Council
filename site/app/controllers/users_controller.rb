class UsersController < ApplicationController

  hobo_user_controller

  auto_actions :all, :except => [ :index, :new, :create ]

  def create
    hobo_create do
      if valid?
        self.current_user = this
        flash[:notice] = t("hobo.messages.you_are_site_admin", :default=>"You are now the site administrator")
        redirect_to home_page
      end
    end
  end

  def voters
    render :json => ::Agenda.voters
  end

  def current_council_slacking
    start = CustomConfig['CouncilTerm']['start_time']
    stop = Agenda.current.meeting_time - 1.minute
    @slackings = ::User.council_member_is(true).collect do |user|
      [user.name, user.slacking_status_in_period(start, stop)]
    end
  end
end
