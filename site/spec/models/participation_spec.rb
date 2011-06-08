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

  describe '.mark_participations' do
    it 'should properly create participations' do
      u = users_factory(:user, :council, :council_admin)
      non_participants = users_factory(:user, :council, :council_admin)
      a = Factory(:agenda)
      Factory(:agenda, :state => 'old')

      results_hash = {
          'Whatever' => { u[0].irc_nick => 'Yes', u[1].irc_nick => 'Yes', u[2].irc_nick => 'Yes'},
          'Something else' => { u[0].irc_nick => 'Yes', u[1].irc_nick => 'No'}
      }

      Participation.mark_participations(results_hash)
      (Participation.all.*.irc_nick - u.*.irc_nick).should be_empty
      (u.*.irc_nick - Participation.all.*.irc_nick).should be_empty
      (u - Participation.all.*.participant).should be_empty
    end
  end
end
