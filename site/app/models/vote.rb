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

  scope :for_item, lambda { |iid| joins(:voting_option).where([
                                        'voting_options.agenda_item_id = ?', iid]) }

  def self.vote_for_option(user, option, council_vote)
    item = option.agenda_item
    old_vote = Vote.for_item(item.id).user_is(user.id).first
    if old_vote.nil?
      Vote.create! :voting_option => option, :user => user, :council_vote => council_vote
    else
      old_vote = Vote.find(old_vote)
      old_vote.voting_option = option
      old_vote.council_vote = council_vote
      old_vote.save!
    end
  end

  protected
    def user_voted_only_once
      return if user.nil?
      return if voting_option.nil?
      return if voting_option.agenda_item.nil?
      other_votes = Vote.for_item(voting_option.agenda_item_id).user_id_is(user_id)
      other_votes = other_votes.id_is_not(id) unless new_record?
      if other_votes.count > 0
        errors.add(:user, 'User can vote only once per agenda item.')
      end
    end
end
