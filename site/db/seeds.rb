require File.expand_path("../../spec/factories.rb", __FILE__)
require File.expand_path("../../spec/support/users_factory.rb", __FILE__)

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
