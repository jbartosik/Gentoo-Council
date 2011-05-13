require 'spec_helper'

describe AgendaItem do
  it 'should allow all registered users to create' do
    a = AgendaItem.new
    for u in users_factory(:user, :council, :admin, :council_admin)
      a.user = u
      a.should be_creatable_by(u)
    end
  end

    it 'should allow only administrators to destroy' do
    a = Factory(:agenda_item)
    for u in users_factory(:guest, :user, :council)
      a.should_not be_destroyable_by(u)
    end
    for u in users_factory(:admin, :council_admin)
      a.user = u
      a.should be_destroyable_by(u)
    end
  end

  it 'should allow owner, council members and administrators to edit and update unassigned items' do
    owner = Factory(:user)
    a = Factory(:agenda_item, :user => owner)
    for u in users_factory(:guest, :user)
      a.should_not be_editable_by(u)
      a.should_not be_updatable_by(u)
    end
    for u in users_factory(:council, :admin, :council_admin) + [owner]
      a.should be_editable_by(u)
      a.should be_updatable_by(u)
    end
  end

  it 'should allow only council members and administrators to edit and update assigned items' do
    owner = Factory(:user)
    agenda = Agenda.last || Factory(:agenda)
    a = Factory(:agenda_item, :user => owner, :agenda => agenda)
    for u in users_factory(:guest, :user) + [owner]
      a.should_not be_editable_by(u)
      a.should_not be_updatable_by(u)
    end
    for u in users_factory(:council, :admin, :council_admin)
      a.should be_editable_by(u)
      a.should be_updatable_by(u)
    end
  end

  it 'should allow no one edit and update items assigned to archived agenda' do
    owner = Factory(:user)
    agenda = Factory(:agenda, :state => 'archived')
    a = Factory(:agenda_item, :user => owner, :agenda => agenda)
    for u in users_factory(AllRoles) + [owner]
      a.should_not be_editable_by(u)
      a.should_not be_updatable_by(u)
    end
  end

  it 'should allow owner, council memebers and administrators to edit some fields' do
    owner = Factory(:user)
    a = Factory(:agenda_item, :user => owner)
    for u in users_factory(:council, :admin, :council_admin) + [owner]
      a.should be_editable_by(u, :title)
      a.should be_editable_by(u, :discussion)
      a.should be_editable_by(u, :body)
    end
  end

  it 'should allow only council memebers and administrators to edit some fields' do
    owner = Factory(:user)
    a = Factory(:agenda_item, :user => owner)
    for u in users_factory(:council, :admin, :council_admin)
      a.should be_editable_by(u, :agenda)
      a.should be_editable_by(u, :rejected)
    end
    a.should_not be_editable_by(owner, :agenda)
    a.should_not be_editable_by(owner, :rejected)
  end

  it 'should allow no one to edit some fields' do
    owner = Factory(:user)
    a = Factory(:agenda_item, :user => owner)
    for u in users_factory(:guest, :user, :council, :admin, :council_admin) + [owner]
      a.should_not be_editable_by(u, :user)
    end
  end

  it 'should not allow to edit agenda if rejected' do
    agenda = Agenda.last || Factory(:agenda)
    a = Factory(:agenda_item, :agenda => agenda)
    for u in users_factory(:guest, :user, :council, :admin, :council_admin)
      a.should_not be_editable_by(u, :rejected)
    end
  end

  it 'should not allow to reject if assigned to agenda' do
    a = Factory(:agenda_item, :rejected => true)
    for u in users_factory(:guest, :user, :council, :admin, :council_admin)
      a.should_not be_editable_by(u, :agenda)
    end
  end
end
