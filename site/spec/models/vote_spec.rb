require 'spec_helper'

describe Vote do
  it 'should allow anyone to create, update and destroy their own votes' do
    for u in users_factory(AllRoles - [:guest]) do
      vote = Factory(:vote, :user => u)
      vote.should be_creatable_by(u)
      vote.should be_updatable_by(u)
      vote.should be_destroyable_by(u)
    end
  end

  it 'should not allow anyone to create, update and destroy vote of someone else' do
    vote = Factory(:vote)
    for u in users_factory(AllRoles) do
      vote.should_not be_creatable_by(u)
      vote.should_not be_updatable_by(u)
      vote.should_not be_destroyable_by(u)
    end
  end

  it 'should allow anyone to view' do
    vote = Factory(:vote)
    for u in users_factory(AllRoles) do
      vote.should be_viewable_by(u)
    end
  end

  it 'should allow all users to vote' do
    for u in users_factory(AllRoles - [:guest]) do
      Vote.new(:user => u, :voting_option => Factory(:voting_option)).should be_valid
    end
  end

  it 'should prevent users from voting multiple times' do
    v = Factory(:vote)
    o = Factory(:voting_option, :agenda_item => v.voting_option.agenda_item, :description => 'other option')
    Vote.new(:user => v.user, :voting_option => o).should_not be_valid
  end

  it 'should prevent users from setting council_vote to true' do
    for u in users_factory(AllRoles - [:guest])
      v = Factory(:vote, :user => u, :council_vote => true)
      v.should_not be_editable_by(u)
      v.should_not be_updatable_by(u)
      v.should_not be_destroyable_by(u)
    end
  end
end
