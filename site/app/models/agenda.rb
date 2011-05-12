class Agenda < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    meeting_time  :datetime
    timestamps
  end

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

end
