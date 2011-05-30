require 'spec_helper'

describe Proxy do
  it 'should require agenda to be set' do
    p = Proxy.new
    p.should_not be_valid
    p.errors.keys.include?(:agenda).should be_true
    p.errors[:agenda].include?("can't be blank").should be_true

    p.agenda = Agenda.current || Factory(:agenda)
    p.valid?
    p.errors.keys.include?(:agenda).should be_false
  end

  it 'should require council member to be set and to be council member' do
    p = Proxy.new
    p.should_not be_valid
    p.errors.keys.include?(:council_member).should be_true
    p.errors[:council_member].include?("can't be blank").should be_true

    p.council_member = Factory(:user)
    p.should_not be_valid
    p.errors.keys.include?(:council_member).should be_true
    p.errors[:council_member].include?('must be council member').should be_true

    p.council_member = users_factory(:council)
    p.valid?
    p.errors.keys.include?(:council_member).should be_false
  end

  it 'should require proxy to be set and not to be council member' do
    p = Proxy.new
    p.should_not be_valid
    p.errors.keys.include?(:proxy).should be_true
    p.errors[:proxy].include?("can't be blank").should be_true

    p.proxy = users_factory(:council)
    p.should_not be_valid
    p.errors.keys.include?(:proxy).should be_true
    p.errors[:proxy].include?('must not be council member').should be_true

    p.proxy = Factory(:user)
    p.valid?
    p.errors.keys.include?(:proxy).should be_false
  end

  it 'should allow only council members to create for their selfs' do
    for u in users_factory(:user, :admin)
      p = Proxy.new :council_member => u
      p.should_not be_creatable_by(u)
    end

    p = Proxy.new :council_member => users_factory(:council_admin)
    for u in users_factory(:council, :council_admin)
      p.should_not be_creatable_by(u)
    end

    for u in users_factory(:council, :council_admin)
      p = Proxy.new :council_member => u
      p.should be_creatable_by(u)
    end
  end

  it 'should allow no one to update or edit' do
    p = Factory(:proxy)
    for u in users_factory(AllRoles) + [p.council_member, p.proxy]
      p.should_not be_editable_by(u)
      p.should_not be_updatable_by(u)
    end
  end


  it 'should allow everyone to view' do
    p = Factory(:proxy)
    for u in users_factory(AllRoles) + [p.council_member, p.proxy]
      p.should be_viewable_by(u)
    end
  end

  it 'should allow council members to destroy their own proxies for current meeting' do
    a = Factory(:agenda)
    p = Factory(:proxy, :agenda => a)
    p.should be_destroyable_by(p.council_member)
  end

  it 'should not allow council members to destroy their own proxies for old meetings' do
    a = Factory(:agenda, :state => 'old')
    p = Factory(:proxy, :agenda => a)
    p.should_not be_destroyable_by(p.council_member)
  end

  it 'should not allow users to destoy someone else proxy' do
    a = Factory(:agenda)
    p = Factory(:proxy, :agenda => a)
    for u in users_factory(AllRoles)
      p.should_not be_destroyable_by(u)
    end
  end

  it 'should remember nick of council member and proxy from time it was created' do
    c = users_factory(:council)
    u = users_factory(:user)
    p = Factory(:proxy, :council_member => c, :proxy => u)
    c_nick = c.irc_nick
    u_nick = u.irc_nick
    u.irc_nick = 'diffrent nick'
    c.irc_nick = 'other nick'
    u.save!
    c.save!
    p.reload
    p.council_member_nick.should == c_nick
    p.proxy_nick.should == u_nick
  end
end
