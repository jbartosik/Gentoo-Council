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
    for u in users_factory(:all_roles)
      v1.should_not be_updatable_by(u)
      v1.should_not be_destroyable_by(u)
      v2.should_not be_updatable_by(u)
      v2.should_not be_destroyable_by(u)
    end
  end

  it 'should allow everyone to view' do
    v = Factory(:voting_option)
    for u in users_factory(:all_roles)
      v.should be_viewable_by(u)
    end
  end

  it 'should return proper community votes count' do
    item = Factory(:agenda_item)
    option_a = Factory(:voting_option, :agenda_item => item, :description => 'a')
    option_b = Factory(:voting_option, :agenda_item => item, :description => 'b')
    (1..3).each { |i| Factory(:vote, :council_vote => false, :voting_option => option_a) }
    (1..7).each { |i| Factory(:vote, :council_vote => false, :voting_option => option_b) }
    option_a.community_votes.should == '3 of 10 (30%) votes.'
    option_b.community_votes.should == '7 of 10 (70%) votes.'
  end
end
