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

class Participation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    irc_nick :string, :default => ""
    timestamps
  end

  belongs_to :participant, :class_name => 'User'
  belongs_to :agenda

  # --- Permissions --- #

  def create_permitted?
    false
  end

  def update_permitted?
    false
  end

  def destroy_permitted?
    false
  end

  def view_permitted?(field)
    true
  end

  def name
    participant.name
  end

  def self.mark_participations(results)
    participant_nicks = results.values.*.keys.flatten.uniq
    agenda = Agenda.current
    for nick in participant_nicks
      user = ::User.find_by_irc_nick(nick)
      unless user.council_member?
        user = Proxy.proxy_is(user).agenda_is(agenda)._?.first.council_member
      end
      next if user.nil?
      Participation.create! :irc_nick => user.irc_nick,
                            :participant => user,
                            :agenda => agenda
    end
  end
end
