require 'spec_helper'

describe Agenda do
  it "shouldn't allow anyone to create and destroy" do
    agendas = [Agenda.new, Factory(:agenda)]
    for a in agendas
      for u in users_factory(AllRoles)
        a.should_not be_creatable_by(u)
        a.should_not be_destroyable_by(u)
      end
    end
  end

  it "shouldn allow everybody to view" do
    agendas = [Agenda.new, Factory(:agenda)]
    for a in agendas
      for u in users_factory(AllRoles)
        a.should be_viewable_by(u)
      end
    end
  end

  it "should allow only administrators and council members to edit and update" do
    agendas = [Agenda.new, Factory(:agenda)]
    for a in agendas
      for u in users_factory(AllRoles)
        a.should_not be_editable_by(u)
        a.should_not be_updatable_by(u)
      end
    end
  end
end
