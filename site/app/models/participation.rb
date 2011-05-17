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
end
