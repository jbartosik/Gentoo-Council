class AgendaItem < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    title      :string
    discussion :string
    body       :text
    rejected   :boolean, :default => false
    timelimits :text, :null => false, :default => ''
    timestamps
  end

  belongs_to :user, :creator => true
  belongs_to :agenda
  has_many   :voting_options

  validate :timelimits_entered_properly

  # --- Permissions --- #
  def create_permitted?
    return false if acting_user.guest?
    return false if user != acting_user
    true
  end

  def update_permitted?
    return false if agenda._?.state == 'old'
    return false if user_changed?
    return true if acting_user.council_member?
    return true if acting_user.administrator?
    return false unless agenda.nil?
    return true if acting_user == user
    false
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

  # Not deduced properly
  def edit_permitted?(field)
    return false if field == :rejected && !agenda.nil?
    return false if field == :agenda && rejected?
    return false if agenda._?.state == 'old'
    return false if field == :user
    return true if acting_user.administrator?
    return true if acting_user.council_member?
    return false unless agenda.nil?
    return acting_user == user if [nil, :title, :discussion, :body].include?(field)
  end

  protected
    def timelimits_entered_properly
      regexp = /^\d+:\d+( .*)?$/
      for line in timelimits.split("\n")
        unless line.match regexp
          errors.add(:timelimits, "Line '#{line}' doensn't match '<minutes>:<seconds> <message>'")
        end
      end
    end
end
