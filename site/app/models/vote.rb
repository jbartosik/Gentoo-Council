#   Gentoo Council Web App - to help Gentoo Council do their job better
#   Copyright (C) 2011 Joachim Filip Bartosik
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as
#   published by the Free Software Foundation, version 3 of the License
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

  validates_presence_of :voting_option, :user
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

  def self.update_user_poll_votes(new_choice, user, item)
    old_choice = Vote.user_is(user).for_item(item).*.voting_option_id
    (old_choice - new_choice).each do |choice_id|
      vote = Vote.user_is(user).voting_option_is(choice_id).first
      next if vote.nil?
      vote.destroy
    end

    (new_choice - old_choice).each do |choice_id|
      next unless VotingOption.find(choice_id).agenda_item_is?(item)
      Vote.create! :user => user, :voting_option_id => choice_id
    end
  end
  protected
    def user_voted_only_once
      return if user.nil?
      return if voting_option.nil?
      return if voting_option.agenda_item.nil?
      return if voting_option.agenda_item.poll
      other_votes = Vote.for_item(voting_option.agenda_item_id).user_id_is(user_id)
      other_votes = other_votes.id_is_not(id) unless new_record?
      if other_votes.count > 0
        errors.add(:user, 'User can vote only once per agenda item.')
      end
    end
end
