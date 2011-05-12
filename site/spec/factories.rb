Factory.sequence :user do |n|
    "user-#{n}"
end

Factory.define :user, :class => User do |u|
  u.name { Factory.next(:user) }
  u.irc_nick { Factory.next(:user) }
  u.email { |u| "#{u.name}@example.com" }
end

Factory.define :guest do |g|; end

Factory.define :agenda do |a|; end