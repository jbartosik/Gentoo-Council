#   Gentoo Council Web App - to help Gentoo Council do their job better
#   Copyright (C) 2011 Joachim Filip Bartosik
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as
#   published by the Free Software Foundation, version 3 of the License
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
