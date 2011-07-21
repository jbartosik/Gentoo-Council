require 'permissions/set.rb'

class Approval < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end

  belongs_to :user, :null => false
  belongs_to :agenda, :null => false

  validates_presence_of :user_id
  validates_presence_of :agenda_id
  validates_uniqueness_of :user_id, :scope => :agenda_id

  def view_permitted?(field)
    true
  end

  multi_permission(:create, :destroy, :update) do
    return false unless user_is?(acting_user)
    return false unless acting_user.council_member?
    true
  end
end
