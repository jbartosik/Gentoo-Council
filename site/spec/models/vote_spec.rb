require 'spec_helper'

describe Vote do
  it 'should not allow anyone to create update or destroy to anyone' do
    vote = Factory(:vote)
    for u in users_factory(AllRoles) do
      vote.should_not be_creatable_by(u)
      vote.should_not be_updatable_by(u)
      vote.should_not be_destroyable_by(u)
    end
  end

  it 'should anyone to view' do
    vote = Factory(:vote)
    for u in users_factory(AllRoles) do
      vote.should be_viewable_by(u)
    end
  end

  it 'should allow council members to vote' do
    for u in users_factory(:council, :council_admin) do
      Vote.new(:user => u, :voting_option => Factory(:voting_option)).should be_valid
    end
  end

  it 'should prevent non-council members from voting' do
    for u in users_factory(:user, :admin) do
      Vote.new(:user => u, :voting_option => Factory(:voting_option)).should_not be_valid
    end
  end

  it 'should prevent users from voting multiple times' do
    v = Factory(:vote)
    o = Factory(:voting_option, :agenda_item => v.voting_option.agenda_item, :description => 'other option')
    Vote.new(:user => v.user, :voting_option => o).should_not be_valid
  end
end
