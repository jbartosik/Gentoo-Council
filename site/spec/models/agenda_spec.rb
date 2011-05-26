require 'spec_helper'

describe Agenda do
  it 'shouldn not allow anyone to create' do
    a = Agenda.new
    for u in users_factory(AllRoles)
      a.should_not be_creatable_by(u)
      a.should_not be_destroyable_by(u)
    end
  end

  it 'shouldn not allow anyone to destory' do
    a = Factory(:agenda)
    for u in users_factory(AllRoles)
      a.should_not be_destroyable_by(u)
    end
  end

  it 'should allow everybody to view' do
    a = Factory(:agenda)
    for u in users_factory(AllRoles)
      a.should be_viewable_by(u)
    end
  end

  it 'should allow only administrators and council members to edit and update' do
    a = Factory(:agenda)
    for u in users_factory(:guest, :user)
      a.should_not be_editable_by(u)
      a.should_not be_updatable_by(u)
    end
  end

  def test_migration(object, migration, prohibited, allowed, final_state)
    # object - object to migrate
    # migration - migration name
    # prohibited - array of users who can not perform migration
    # allowed - *one* user who can perform migration
    # final_state - state of object after migration
    for user in prohibited
      lambda { object.lifecycle.send("#{migration}!", user) }.should raise_error
    end

    object.lifecycle.send("#{migration}!", allowed)
    object.state.should == final_state
  end

  it 'should have working transitions, available only to council members and administrators' do
    Factory(:agenda)
    prohibited = users_factory(:guest, :user)
    allowed = users_factory(:council, :admin, :council_admin)

    for user in allowed
      agenda = Agenda.last
      test_migration(agenda, :close, prohibited, user, 'submissions_closed')
      test_migration(agenda, :reopen, prohibited, user, 'open')
      test_migration(agenda, :close, prohibited, user, 'submissions_closed')
      test_migration(agenda, :archive, prohibited, user, 'old')
    end

  end

  it 'that is non-archival should not be valid if there other open agenda' do
    a = Factory(:agenda)
    Agenda.new.should_not be_valid
    Agenda.new(:state => 'submissions_closed').should_not be_valid
  end

  it 'that is non-archival should not be valid if there other closed agenda' do
    a = Factory(:agenda, :state => 'submissions_closed')
    Agenda.new.should_not be_valid
    Agenda.new(:state => 'submissions_closed').should_not be_valid
  end

  it 'that is archival should be valid' do
    a = Factory(:agenda, :state => 'old')
    a.should be_valid
  end

  it 'should create new open agenda, when current agenda is archived' do
    a = Factory(:agenda)
    u = users_factory(:admin)
    a.lifecycle.close! u
    a.lifecycle.archive! u
    Agenda.last.state.should == 'open'
  end

  it 'should set meeting time to now by default' do
    a1 = Factory(:agenda)
    a2 = Factory(:agenda, :meeting_time => 2.days.ago, :state => 'old')
    today = Time.now.strftime('%Y-%m-%d')

    a1.meeting_time.strftime('%Y-%m-%d').should == today
    a2.meeting_time.strftime('%Y-%m-%d').should_not == today
  end

  it 'should add all council members and only them as participants when archived' do
    users_factory(:user, :admin)
    users_factory(:council, :council)
    council_names = User.council_member_is(true).collect{ |c| c.name }
    agenda = Factory(:agenda, :state => 'submissions_closed')
    agenda.lifecycle.archive!(User.council_member_is(true).first)

    (council_names - agenda.participations.*.participant.*.name).should be_empty
    (agenda.participations.*.participant.*.name - council_names).should be_empty
  end
  it 'should properly create votes' do
    Factory(:agenda)
    a1 = Factory(:agenda_item, :agenda => Agenda.current)
    a2 = Factory(:agenda_item, :agenda => Agenda.current)
    a3 = Factory(:agenda_item, :agenda => Agenda.current)
    Agenda.current.agenda_items.each do |item|
      Factory(:voting_option, :agenda_item => item, :description => 'Yes')
      Factory(:voting_option, :agenda_item => item, :description => 'No')
      Factory(:voting_option, :agenda_item => item, :description => 'Dunno')
    end

    u = users_factory(:council, :council, :council)
    Vote.count.should be_zero

    results_hash = {
        a1.title => { u[0].irc_nick => 'Yes', u[1].irc_nick => 'Yes', u[2].irc_nick => 'Yes'},
        a2.title => { u[0].irc_nick => 'Yes', u[1].irc_nick => 'No', u[2].irc_nick => 'Dunno'},
        a3.title => { u[0].irc_nick => 'Dunno', u[1].irc_nick => 'Dunno', u[2].irc_nick => 'No'}
    }

    Agenda.process_results results_hash

    Vote.count.should be_equal(9)

    u[0].votes.*.voting_option.*.description.should == ['Yes', 'Yes', 'Dunno']
    u[1].votes.*.voting_option.*.description.should == ['Yes', 'No', 'Dunno']
    u[2].votes.*.voting_option.*.description.should == ['Yes', 'Dunno', 'No']
    a1.voting_options.*.votes.flatten.*.voting_option.*.description.should == ['Yes', 'Yes', 'Yes']
    a2.voting_options.*.votes.flatten.*.voting_option.*.description.should == ['Yes', 'No', 'Dunno']
    a3.voting_options.*.votes.flatten.*.voting_option.*.description.should == ['No', 'Dunno', 'Dunno']
  end
end
