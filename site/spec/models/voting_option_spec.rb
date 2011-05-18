require 'spec_helper'

describe VotingOption do
  it 'should allow only council members to create' do
    v = Factory(:voting_option)
    for u in users_factory(:guest, :user, :admin)
      v.should_not be_creatable_by(u)
    end

    for u in users_factory(:council, :council_admin)
      v.should be_creatable_by(u)
    end
  end

  it 'should allow only council members to update and destroy if it belongs to open agenda' do
    v = Factory(:voting_option)
    for u in users_factory(:guest, :user, :admin)
      v.should_not be_updatable_by(u)
      v.should_not be_destroyable_by(u)
    end
    for u in users_factory(:council, :council_admin)
      v.should be_updatable_by(u)
      v.should be_destroyable_by(u)
    end
  end

  it 'should allow no one to update and destroy if it belongs to closed or archived agenda' do
    a1 = Factory(:agenda, :state => 'closed')
    i1 = Factory(:agenda_item, :agenda => a1)
    v1 = Factory(:voting_option, :agenda_item => i1)
    a2 = Factory(:agenda, :state => 'old')
    i2 = Factory(:agenda_item, :agenda => a2)
    v2 = Factory(:voting_option, :agenda_item => i2)
    for u in users_factory(AllRoles)
      v1.should_not be_updatable_by(u)
      v1.should_not be_destroyable_by(u)
      v2.should_not be_updatable_by(u)
      v2.should_not be_destroyable_by(u)
    end
  end
end
