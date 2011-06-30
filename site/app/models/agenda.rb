class Agenda < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    meeting_time        :datetime
    email_reminder_sent :boolean, :null => false, :default => false
    meeting_log         :text, :null => false, :default => ''
    timestamps
  end

  has_many :agenda_items
  has_many :participations
  has_many :proxies

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
    return false if meeting_log_changed?
    return true  if acting_user.council_member?
    return true  if acting_user.administrator?
    false
  end

  def destroy_permitted?
    false
  end

  def view_permitted?(field)
    true
  end

  before_create do |agenda|
    agenda.meeting_time ||= Time.now
  end

  def self.current
    result = Agenda.state_is_not(:old).first
    result = Agenda.create! unless result
    result
  end

  def self.transitions_available(user)
    return user if user.council_member?
    return user if user.administrator?
    false
  end

  def self.update_voting_options(options)
    agenda = Agenda.current
    options.each do |item_info|
      item = AgendaItem.first :conditions => { :agenda_id => agenda, :title => item_info.first }
      new_descriptions = item_info[1]
      old_descriptions = item.voting_options.*.description

      (old_descriptions - new_descriptions).each do |description|
        option = VotingOption.first :conditions => { :agenda_item_id => item.id,
                                                      :description => description }
        option.destroy
      end

      (new_descriptions - old_descriptions ).each do |description|
        VotingOption.create! :agenda_item => item, :description => description
      end
    end
  end

  def self.process_results(results)
    agenda = Agenda.current
    for item_title in results.keys
      item = AgendaItem.first :conditions => { :agenda_id => agenda, :title => item_title }
      votes = results[item_title]
      for voter in votes.keys
        option = VotingOption.first :conditions => { :agenda_item_id => item.id, :description => votes[voter] }
        user = ::User.find_by_irc_nick voter
        Vote.vote_for_option(user, option, true)
      end
    end
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

  def current?
    ['open', 'submissions_closed', 'meeting_ongoing'].include?(state.to_s)
  end

  def voting_array
    agenda_items.collect do |item|
      [item.title, item.voting_options.*.description, item.timelimits]
    end
  end

  def time_for_reminders(type)
    offset = CustomConfig['Reminders']["hours_before_meeting_to_send_#{type}_reminders"].hours
    meeting_time - offset
  end

  def self.voters_users
    # It's possible to rewrite this as SQL, but
    #  * this method is rarely called
    #  * it fetches little data
    # So I think efficiency improvement would be insignificant.
    # Joachim
    council = ::User.council_member_is(true)
    proxies = Agenda.current.proxies.*
    [council - proxies.council_member + proxies.proxy].flatten
  end

  def self.voters
    Agenda.voters_users.*.irc_nick
  end

  def self.send_current_agenda_reminders
    agenda = Agenda.current

    return if agenda.email_reminder_sent?
    return if Time.now < agenda.time_for_reminders(:email)

    for user in Agenda.voters_users
      UserMailer.delay.deliver_meeting_reminder(user, agenda)
    end

    agenda.email_reminder_sent = true
    agenda.save!
  end

  def self.irc_reminders
    agenda = Agenda.current
    meeting_time = agenda.meeting_time.strftime('%a %b %d %H:%M:%S %Y')
    return {} if Time.now < agenda.time_for_reminders(:irc)
    return { 'remind_time' => meeting_time,
              'message' => "Remember about council meeting on #{meeting_time}",
              'users' => Agenda.voters}
  end

  before_save do |agenda|
    return true if agenda.new_record?
    return true unless agenda.meeting_time_changed?
    agenda.email_reminder_sent = false
    true
  end

  after_save do |agenda|
    if agenda.new_record? or agenda.meeting_time_changed?
      Agenda.delay(:run_at => agenda.time_for_reminders(:email)).send_current_agenda_reminders
    end
  end

  protected
    def there_is_only_one_non_archival_agenda
      return if(state.to_s == 'old')
      not_old_agendas = Agenda.state_is_not(:old)
      if id.nil?
        return if not_old_agendas.count == 0
      else
        return if not_old_agendas.id_is_not(id).count == 0
      end
      errors.add(:state, 'There can be only one non-archival agenda at time.')
    end
end
