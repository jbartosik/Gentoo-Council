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

def users_factory(*roles)
  roles.flatten!
  roles.collect! do |role|
    case role
      when :all_roles
        [:guest, :user, :council, :admin, :council_admin]
      when :registered
        [:user, :council, :admin, :council_admin]
      else
        role
    end
  end
  roles.flatten!

  r = []
  roles
  for role in roles
    case role
      when :guest
        r.push Guest.new
      when :user
        r.push Factory(:user)
      when :council
        r.push Factory(:user, :council_member => true)
      when :admin
        r.push Factory(:user, :administrator => true)
      when :council_admin
        r.push Factory(:user, :council_member => true, :administrator => true)
    end
  end
  (r.count < 2) ? r.first : r
end
