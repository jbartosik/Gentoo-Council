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

def vote(user, item, option_description)
  option = VotingOption.agenda_item_is(item).description_is(option_description).first
  Factory(:vote, :voting_option => option, :user => user, :council_vote => true)
end

def make_votes(council, item_title, accepting_votes)
  item = AgendaItem.find_by_title(item_title)
  council.inject(0) do |counter, user|
    if counter < accepting_votes
      vote(user, item, "Accept")
    else
      vote(user, item, "Reject")
    end
    counter += 1
  end
end

yml_seed_path = File.expand_path("../seed.yml", __FILE__)
yml_seed_file = File.open(yml_seed_path)
seed = YAML::load(yml_seed_file)

[Agenda, AgendaItem, Participation, Proxy, User, Vote, VotingOption].each do |model|
  # Refresh table_exists cache for all models
  model.table_exists?(true)
end

seed.each do |agenda_desc|
  state = agenda_desc['state']
  agenda = state.nil? ? nil : Factory(:agenda, :state => state)

  agenda_desc['agenda_items']._?.each do |item_desc|
    rejected = item_desc['rejected']
    rejected = rejected.nil? ? false : rejected
    item = Factory(:agenda_item, :title => item_desc['title'],
                            :body => item_desc['body'],
                            :rejected => rejected,
                            :agenda => agenda)

    item_desc['voting_options']._?.each do |option_desc|
      Factory(:voting_option, :description => option_desc, :agenda_item => item)
    end
  end
end

council = users_factory([:council] * 7)

make_votes(council, "Accepted item", 5)
make_votes(council, "Rejected item", 3)
