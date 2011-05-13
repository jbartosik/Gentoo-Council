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
end
