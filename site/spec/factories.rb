Factory.sequence :user do |n|
    "user-#{n}"
end

Factory.define :user, :class => User do |u|
  u.name { Factory.next(:user) }
  u.irc_nick { Factory.next(:user) }
  u.email { |u| "#{u.name}@example.com" }
end

Factory.define :agenda do |a|; end

Factory.define :agenda_item do |a|
  a.sequence(:title) { |n| "Agenda Item #{n}" }
end

Factory.define :participation do |p|; end

Factory.define :vote do |v|;
  v.association :voting_option
  v.user        { users_factory(:council) }
end

Factory.define :voting_option  do |v|;
  v.agenda_item { AgendaItem.create! }
  v.description { "example" }
end
