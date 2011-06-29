require 'permissions/set.rb'
class Vote < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end

  belongs_to :voting_option, :null => false
  belongs_to :user, :null => false, :creator => true

  index [:voting_option_id, :user_id], :unique => true

  validates_presence_of :voting_option
  validates_presence_of :user
  validates_uniqueness_of :voting_option_id, :scope => :user_id
  validate :user_voted_only_once
  # --- Permissions --- #

  def create_permitted?
    user_is?(acting_user)
  end

  multi_permission(:update, :destroy) do
    user_is?(acting_user) and not user_changed?
  end

  def view_permitted?(field)
    true
  end

  protected
    def user_voted_only_once
      return if user.nil?
      return if voting_option.nil?
      return if voting_option.agenda_item.nil?
      other_votes = Vote.joins(:voting_option).where(['voting_options.agenda_item_id = ? AND votes.user_id = ?',
                                                        voting_option.agenda_item_id, user_id])
      other_votes = other_votes.id_is_not(id) unless new_record?
      if other_votes.count > 0
        errors.add(:user, 'User can vote only once per agenda item.')
      end
    end
end
