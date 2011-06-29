require 'permissions/set.rb'
class Vote < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    council_vote  :boolean, :null => false, :default => false
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
    return false if council_vote
    user_is?(acting_user)
  end

  multi_permission(:update, :destroy) do
    return false if user_changed?
    return false if council_vote
    user_is?(acting_user)
  end

  def view_permitted?(field)
    true
  end

  def council_vote_edit_permitted?
    false
  end

  named_scope :user_for_item, lambda { |uid, iid| joins(:voting_option).where([
                                        'voting_options.agenda_item_id = ? AND votes.user_id = ?',
                                        iid, uid]) }
  protected
    def user_voted_only_once
      return if user.nil?
      return if voting_option.nil?
      return if voting_option.agenda_item.nil?
      other_votes = Vote.user_for_item(user_id, voting_option.agenda_item_id)
      other_votes = other_votes.id_is_not(id) unless new_record?
      if other_votes.count > 0
        errors.add(:user, 'User can vote only once per agenda item.')
      end
    end
end
