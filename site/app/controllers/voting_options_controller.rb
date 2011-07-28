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

class VotingOptionsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  def community_vote
    option = VotingOption.find(params[:id])
    if option.nil?
      flash[:notice] = "No such voting option"
      redirect_to :controller => :agendas, :action => :index
    else
      if current_user.signed_up?
        Vote.vote_for_option(current_user, option, false)
        flash[:notice] = "You voted for #{option.description}"
      else
        flash[:notice] = "You must be logged in to vote"
      end
      redirect_to :controller => :agenda_items, :action => :show, :id => option.agenda_item_id
    end
  end
end
