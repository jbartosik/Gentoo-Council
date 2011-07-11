class User < ActiveRecord::Base

  hobo_devise_user_model :auth_methods => [:database_authenticable]

  fields do
    name            :string, :required, :unique
    irc_nick        :string, :required, :unique
    email           :email_address, :login => true
    administrator   :boolean, :default => false
    council_member  :boolean, :default => false
    timestamps
  end

  has_many  :votes
  # --- Signup lifecycle --- #

  lifecycle do

    state :active, :default => true

    create :signup, :available_to => "Guest",
           :params => [:name, :email, :irc_nick, :password, :password_confirmation],
           :become => :active

    transition :request_password_reset, { :active => :active }, :new_key => true do
      UserMailer.forgot_password(self, lifecycle.key).deliver
    end

    transition :reset_password, { :active => :active }, :available_to => :key_holder,
               :params => [ :password, :password_confirmation ]

  end

  # --- Permissions --- #

  def create_permitted?
    false
  end

  def update_permitted?
    acting_user.administrator? ||
      (acting_user == self && only_changed?(:email, :crypted_password,
                                            :current_password, :password,
                                            :password_confirmation, :irc_nick))
    # Note: crypted_password has attr_protected so although it is permitted to change, it cannot be changed
    # directly from a form submission.
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

  def slacking_status_in_period(start_date, end_date)
    num_status = 0
    agendas = Agenda.all :conditions => ['agendas.meeting_time BETWEEN ? AND ?', start_date, end_date],
                          :order => :meeting_time

    return 'There were no meetings in this term yet' if agendas.count.zero?

    for agenda in agendas
      if Participation.participant_is(self).agenda_is(agenda).count == 0
        num_status += 1 if num_status < 3
      else
        num_status = 0 if num_status == 1
      end
    end

    text_statuses = ['Was on last meeting', 'Skipped last meeting',
          'Slacker', 'No more a council']
    text_statuses[num_status]
  end

  def can_appoint_a_proxy?(user)
    agenda = Agenda.current
    return false unless council_member?
    return false if user.council_member?
    return false unless Proxy.council_member_is(self).agenda_is(agenda).count ==  0
    return false unless Proxy.proxy_is(user).agenda_is(agenda).count ==  0
    true
  end
end
