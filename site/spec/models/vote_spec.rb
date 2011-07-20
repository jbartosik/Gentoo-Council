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

describe Vote do
  it 'should allow anyone to create, update and destroy their own votes' do
    for u in users_factory(:registered) do
      vote = Factory(:vote, :user => u)
      vote.should be_creatable_by(u)
      vote.should be_updatable_by(u)
      vote.should be_destroyable_by(u)
    end
  end

  it 'should not allow anyone to create, update and destroy vote of someone else' do
    vote = Factory(:vote)
    for u in users_factory(:all_roles) do
      vote.should_not be_creatable_by(u)
      vote.should_not be_updatable_by(u)
      vote.should_not be_destroyable_by(u)
    end
  end

  it 'should allow anyone to view' do
    vote = Factory(:vote)
    for u in users_factory(:all_roles) do
      vote.should be_viewable_by(u)
    end
  end

  it 'should allow all users to vote' do
    for u in users_factory(:registered) do
      Vote.new(:user => u, :voting_option => Factory(:voting_option)).should be_valid
    end
  end

  it 'should prevent users from voting multiple times' do
    v = Factory(:vote)
    o = Factory(:voting_option, :agenda_item => v.voting_option.agenda_item, :description => 'other option')
    Vote.new(:user => v.user, :voting_option => o).should_not be_valid
  end

  it 'should allow users to voting for multiple options in polls' do
    item = Factory(:agenda_item, :poll => true)
    option1 = Factory(:voting_option, :agenda_item => item, :description => 'option')
    option2 = Factory(:voting_option, :agenda_item => item, :description => 'other option')
    user = users_factory(:user)

    Factory(:vote, :user => user, :voting_option => option1)
    Vote.new(:user => user, :voting_option => option2).should be_valid
    Vote.new(:user => user, :voting_option => option1).should_not be_valid
  end

  it 'should prevent users from setting council_vote to true' do
    for u in users_factory(:registered)
      v = Factory(:vote, :user => u, :council_vote => true)
      v.should_not be_editable_by(u)
      v.should_not be_updatable_by(u)
      v.should_not be_destroyable_by(u)
    end
  end
end
