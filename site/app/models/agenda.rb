class Agenda < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    meeting_time  :datetime
    timestamps
  end

  lifecycle do
    state :open, :default => true
    state :submissions_closed, :meeting_ongoing, :old

    transition :close, {:open => :submissions_closed}, :available_to => '::Agenda.transitions_available(acting_user)'
    transition :reopen, {:submissions_closed=> :open}, :available_to => '::Agenda.transitions_available(acting_user)'
    transition :archive, {:submissions_closed => :old}, :available_to =>  '::Agenda.transitions_available(acting_user)' do
      Agenda.new.save!
    end
  end

  validate  :there_is_only_one_non_archival_agenda

  # --- Permissions --- #

  def create_permitted?
    false
  end

  def update_permitted?
    acting_user.council_member? || acting_user.administrator?
  end

  def destroy_permitted?
    false
  end

  def view_permitted?(field)
    true
  end

  before_create do |a|
    a.meeting_time ||= Time.now
  end

  def self.current
    Agenda.state_is_not(:old).first
  end

  def self.transitions_available(user)
    return user if user.council_member?
    return user if user.administrator?
    false
  end

  def possible_transitions
    transitions = case state
      when 'open'
        ['close']
      when 'submissions_closed'
        ['reopen', 'archive']
      else
        []
    end

    transitions.collect do |transition|
      ["#{transition.camelize} this agenda.", "agenda_#{transition}_path"]
    end
  end

  protected
    def there_is_only_one_non_archival_agenda
      return if(state.to_s == 'old')
      if id.nil?
        return if Agenda.state_is_not(:old).count == 0
      else
        return if Agenda.state_is_not(:old).id_is_not(id).count == 0
      end
      errors.add(:state, 'There can be only one non-archival agenda at time.')
    end
end
