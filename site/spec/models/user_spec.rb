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

  describe '.slacking_status_in_period' do
    it 'should give "Was on last meeting" slacking status to user who was on all meetings' do
      u = users_factory(:council)
      agendas = (1..10).collect do |i|
        a = Factory(:agenda, :state => 'old')
        Factory(:participation, :participant => u, :agenda => a)
        a
      end
      u.slacking_status_in_period(agendas.first.meeting_time - 1.minute,
                                    agendas.last.meeting_time + 1.minute).should == 'Was on last meeting'
    end

    it 'should give "Was on last meeting" slacking status to user who was on last meeting and skipped some meetings in past (but not two consecutive)' do
      u = users_factory(:council)
      agendas = (1..10).collect do |i|
        a = Factory(:agenda, :state => 'old')
        Factory(:participation, :participant => u, :agenda => a) if i.even?
        a
      end
      u.slacking_status_in_period(agendas.first.meeting_time - 1.minute,
                                    agendas.last.meeting_time + 1.minute).should == 'Was on last meeting'
    end

    it 'should give "Skipped last meeting" slacking status to user who was absent on last meeting and skipped some meetings in past (but not two consecutive)' do
      u = users_factory(:council)
      agendas = (1..10).collect do |i|
        a = Factory(:agenda, :state => 'old')
        Factory(:participation, :participant => u, :agenda => a) if i.odd?
        a
      end
      u.slacking_status_in_period(agendas.first.meeting_time - 1.minute,
                                    agendas.last.meeting_time + 1.minute).should == 'Skipped last meeting'
    end

    it 'should give "Slacker" slacking status to user who was present on last meeting skipped two consecutive meeting in the past' do
      u = users_factory(:council)
      agendas = (1..10).collect do |i|
        a = Factory(:agenda, :state => 'old')
        Factory(:participation, :participant => u, :agenda => a) unless [1, 3, 5, 6].include?(i)
        a
      end
      u.slacking_status_in_period(agendas.first.meeting_time - 1.minute,
                                    agendas.last.meeting_time + 1.minute).should == 'Slacker'
    end

    it 'should give "No more a council" slacking status to user who skipped two consecutive meeting in the past and the last one' do
      u = users_factory(:council)
      agendas = (1..10).collect do |i|
        a = Factory(:agenda, :state => 'old')
        Factory(:participation, :participant => u, :agenda => a) unless [1, 3, 5, 6, 10].include?(i)
        a
      end
      u.slacking_status_in_period(agendas.first.meeting_time - 1.minute,
                                    agendas.last.meeting_time + 1.minute).should == 'No more a council'
    end

    it 'should give "No more a council" slacking status to user who skipped two consecutive meeting in the past and then one more' do
      u = users_factory(:council)
      agendas = (1..10).collect do |i|
        a = Factory(:agenda, :state => 'old')
        Factory(:participation, :participant => u, :agenda => a) unless [5, 6, 8].include?(i)
        a
      end
      u.slacking_status_in_period(agendas.first.meeting_time - 1.minute,
                                    agendas.last.meeting_time + 1.minute).should == 'No more a council'
    end

    it 'should return "There were no meetings in this term yet" if there were no meeting yet' do
      a = Factory(:agenda, :meeting_time => 1.year.from_now)
      u = users_factory(:council)
      u.slacking_status_in_period(1.year.ago, 1.month.from_now).should == "There were no meetings in this term yet"
    end
  end

  it 'should allow no one to create' do
    for u in users_factory(:all_roles)
      User.new.should_not be_creatable_by(u)
    end
  end

  it 'should allow only administrators to destroy' do
    for u in users_factory(:user, :council, :guest)
      Factory(:user).should_not be_destroyable_by(u)
    end

    for u in users_factory(:admin, :council_admin)
      Factory(:user).should be_destroyable_by(u)
    end
  end

  it 'should allow everybody to view' do
    for u1 in users_factory(:all_roles)
      for u2 in users_factory(:registered)
        u2.should be_viewable_by(u1)
      end
    end
  end

  describe '#updatable_by?' do
    it 'should return true if user changes own email, irc_nick and password' do
      u = Factory(:user)
      u.password = 'changed'
      u.password_confirmation = 'changed'
      u.current_password = 'changed'
      u.crypted_password = 'changed'
      u.irc_nick = 'changed'
      u.email = 'changed@changed.com'
      u.should be_updatable_by u
    end

    it 'should return false if user changes someone' do
      u = Factory(:user)
      u.should_not be_updatable_by(Factory(:user))
    end

    it 'should return true if administrator changes something' do
      u = Factory(:user)
      u.password = 'changed'
      u.password_confirmation = 'changed'
      u.current_password = 'changed'
      u.crypted_password = 'changed'
      u.email = 'changed@changed.com'
      u.irc_nick = 'changed'
      u.administrator = true
      u.council_member = true
      u.should be_updatable_by(users_factory(:admin))
    end

  end

  describe '#can_appoint_a_proxy?' do
    it 'should return false for users who are not council members' do
      for u in users_factory(:user, :admin, :guest)
        proxy = Factory(:user)
        u.can_appoint_a_proxy?(proxy).should be_false
      end
    end

    it 'should return true for council members who never appointed a proxy' do
      for u in users_factory(:council, :council_admin)
        proxy = Factory(:user)
        u.can_appoint_a_proxy?(proxy).should be_true
      end
    end

    it 'should return true for council members who appointed a proxy for past meeting' do
      Factory(:agenda)
      old_a = Factory(:agenda, :state => 'old')
      for u in users_factory(:council, :council_admin)
        proxy = Factory(:user)
        Factory(:proxy, :council_member => u, :agenda => old_a)
        u.can_appoint_a_proxy?(proxy).should be_true
      end
    end

    it 'should return false for council members who appointed a proxy for current meeting' do
      current_a = Factory(:agenda)
      proxy = Factory(:user)
      for u in users_factory(:council, :council_admin)
        Factory(:proxy, :council_member => u, :agenda => current_a)
        u.can_appoint_a_proxy?(proxy).should be_false
      end
    end

    it 'should return false for council members checking if they can appoint another council member as proxy' do
      proxy = users_factory(:council)
      for u in users_factory(:council, :council_admin)
        u.can_appoint_a_proxy?(proxy).should be_false
      end
    end

    it 'should return false for council members checking if they can appoint someone who is a aleady a proxy for current meeting as proxy' do
      a = Factory(:agenda)
      proxy = users_factory(:user)
      Factory(:proxy, :proxy => proxy, :agenda => a)
      for u in users_factory(:council, :council_admin)
        u.can_appoint_a_proxy?(proxy).should be_false
      end
    end
  end
end
