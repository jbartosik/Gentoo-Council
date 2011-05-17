require 'spec_helper'

describe Participation do
  it 'should not allow anyone to create, edit, update or destroy' do
    p = Factory(:participation)
    for u in users_factory(AllRoles)
      p.should_not be_creatable_by(u)
      p.should_not be_editable_by(u)
      p.should_not be_updatable_by(u)
      p.should_not be_destroyable_by(u)
    end
  end

  it 'should allow everybody to view' do
    p = Factory(:participation)
    for u in users_factory(AllRoles)
      p.should be_viewable_by(u)
    end
  end
end
