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

require 'spec_helper'

describe Participation do
  it 'should not allow anyone to create, edit, update or destroy' do
    p = Factory(:participation)
    for u in users_factory(:all_roles)
      p.should_not be_creatable_by(u)
      p.should_not be_editable_by(u)
      p.should_not be_updatable_by(u)
      p.should_not be_destroyable_by(u)
    end
  end

  it 'should allow everybody to view' do
    p = Factory(:participation)
    for u in users_factory(:all_roles)
      p.should be_viewable_by(u)
    end
  end

  describe '.mark_participations' do
    it 'should properly create participations' do
      u = users_factory(:user, :council, :council_admin)
      non_participants = users_factory(:user, :council, :council_admin)
      a = Factory(:agenda)
      Factory(:agenda, :state => 'old')

      Factory(:proxy, :proxy => u.first,
                      :council_member => non_participants.last,
                      :agenda => a)

      results_hash = {
          'Whatever' => { u[0].irc_nick => 'Yes', u[1].irc_nick => 'Yes', u[2].irc_nick => 'Yes'},
          'Something else' => { u[0].irc_nick => 'Yes', u[1].irc_nick => 'No'}
      }

      present = u - [u.first] + [non_participants.last]
      Participation.mark_participations(results_hash)
      (Participation.all.*.irc_nick - present.*.irc_nick).should be_empty
      (present.*.irc_nick - Participation.all.*.irc_nick).should be_empty
      (present - Participation.all.*.participant).should be_empty
      (Participation.all.*.participant - present).should be_empty
    end
  end
end
