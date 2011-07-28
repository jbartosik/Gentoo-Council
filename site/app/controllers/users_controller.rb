class UsersController < ApplicationController

  hobo_user_controller

  auto_actions :all, :except => [ :index, :new, :create, :do_signup ]

  def do_signup
    do_creator_action(:signup) do
      if valid?
        flash[:notice] = ht(:"#{model.to_s.underscore}.messages.signup.success", :default=>["Thanks for signing up!"])
      else
        this.password = HoboFields::Types::PasswordString.new
        this.password_confirmation = HoboFields::Types::PasswordString.new
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
