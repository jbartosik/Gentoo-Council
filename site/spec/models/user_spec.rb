require 'spec_helper.rb'

describe User do
  it "should run spec test with shoulda and models from application" do
    Guest.new.should_not be_administrator
  end

  it "should set correct roles for new user" do
    u = User.new :name => 'Example', :email => 'example@example.com',
                  :password => 'Example', :irc_nick => 'example'
    u.save!
    u.should_not be_administrator
    u.should_not be_council_member
    u.should_not be_guest
    u.should     be_signed_up
  end
end
