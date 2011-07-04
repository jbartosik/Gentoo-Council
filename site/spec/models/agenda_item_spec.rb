require 'spec_helper'
require 'support/http_stub.rb'

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
    agenda = Factory(:agenda, :state => 'old')
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

  it 'should make sure timelimits are valid' do
    valid_timelimits = ["", "0:0", "1:1 message", "1:2 longer message",
                        "30:40 a few messages\n5:60 as separate lines"]
    invalid_timelimits = ["a:0", "1:", "2:a", ":0", " 1:1 message",
                          "30:40 a few messages\n\n5:60 and an empty line",
                          "30:40 a few messages\n5:60 and an wrong line\na:"]

    valid_timelimits.each do |limit|
      Factory(:agenda_item, :timelimits => limit).should be_valid
    end

    invalid_timelimits.each do |limit|
      item = AgendaItem.new :title => 'title', :timelimits => limit
      item.should_not be_valid
      item.errors.length.should be_equal(1)
      item.errors[:timelimits].should_not be_nil
    end
  end

  describe '.update_discussion_time' do
    it 'should do nothing if discussion is not url to discussion on gentoo archives' do
      items = [Factory(:agenda_item),
                Factory(:agenda_item, :discussion_time => 'something'),
                Factory(:agenda_item, :discussion => 'http://archives.gentoo.org/gentoo-bsd/'),
                Factory(:agenda_item, :discussion_time => 'something',
                                      :discussion => 'http://archives.gentoo.org/gentoo-bsd/')]
      items.each do |item|
        lambda {
          item.send(:update_discussion_time)
        }.should_not change(item, :discussion_time)
      end
    end



    it 'should set discussion_time properly if discussion is url to discussion on gentoo archives' do
      item = Factory(:agenda_item,
                      :discussion =>
                        'http://archives.gentoo.org/gentoo-soc/msg_e490369a0c7e6c279af9baef63897629.xml')
      lambda {
        item.send(:update_discussion_time)
      }.should change(item, :discussion_time).from('').to('From 2011.05.30 to 2011.06.28, 28 full days')
    end
  end
end
