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
  end
end
