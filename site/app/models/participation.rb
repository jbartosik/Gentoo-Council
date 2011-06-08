class Participation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    irc_nick :string
    timestamps
  end

  belongs_to :participant, :class_name => 'User'
  belongs_to :agenda

  # --- Permissions --- #

  def create_permitted?
    false
  end

  def update_permitted?
    false
  end

  def destroy_permitted?
    false
  end

  def view_permitted?(field)
    true
  end

  def name
    participant.name
  end

  def self.mark_participations(results)
    participant_nicks = results.values.*.keys.flatten.uniq
    agenda = Agenda.current
    for nick in participant_nicks
      user = ::User.find_by_irc_nick(nick)
      next if user.nil?
      Participation.create! :irc_nick => user.irc_nick,
                            :participant => user,
                            :agenda => agenda
    end
  end
end
