require 'spec_helper'

describe Approval do
  it 'should be viewable by everybody' do
    approval = Factory(:approval)
    for user in users_factory(:all_roles)
      approval.should be_viewable_by(user)
    end
  end

  it 'only council members should be able to change it - and only for themselves' do
    for user in users_factory(:council, :council_admin)
      approval = Factory(:approval, :user => user)
      approval.should be_creatable_by(user)
      approval.should be_editable_by(user)
      approval.should be_updatable_by(user)
      approval.should be_destroyable_by(user)
    end

    approval = Factory(:approval)
    for user in users_factory(:council, :council_admin)
      approval.should_not be_creatable_by(user)
      approval.should_not be_editable_by(user)
      approval.should_not be_updatable_by(user)
      approval.should_not be_destroyable_by(user)
    end

    for user in users_factory(:user, :admin)
      approval = Approval.new :user => user, :agenda => Agenda.current
      approval.should_not be_creatable_by(user)
      approval.should_not be_editable_by(user)
      approval.should_not be_updatable_by(user)
      approval.should_not be_destroyable_by(user)
    end
  end
end
