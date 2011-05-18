class VotingOption < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    description :string
    timestamps
  end

  belongs_to  :agenda_item, :null => false
  has_many    :votes

  validates_presence_of :agenda_item
  validates_uniqueness_of :description, :scope => :agenda_item_id

  def name
    description
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.council_member?
  end

  def update_permitted?
    return false unless acting_user.council_member?
    return true if agenda_item.nil?
    return true if agenda_item.agenda.nil?
    return true if agenda_item.agenda.state == 'open'
    false
  end

  def destroy_permitted?
    updatable_by?(acting_user)
  end

  def view_permitted?(field)
    true
  end
end
