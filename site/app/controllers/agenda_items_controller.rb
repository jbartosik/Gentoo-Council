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

class AgendaItemsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  before_filter :login, :except => :show

  def update_poll_answers
    new_choice = params[:choice].keys.collect { |txt| txt.to_i }
    item = AgendaItem.find(params[:agenda_item_id])

    Vote.update_user_poll_votes(new_choice, current_user, item)

    redirect_to agenda_item_path(item)
  end

  protected
    def login
      redirect_to user_login_path unless current_user.signed_up?
    end
end
