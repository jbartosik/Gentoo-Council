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

class AgendaItem < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    title      :string, :default => ""
    discussion :string, :default => ""
    body       :markdown, :default => ""
    rejected   :boolean, :default => false
    timelimits :text, :default => ""
    discussion_time :string
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
    return false if discussion_time_changed?
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

  def update_voting_options(new_descriptions)
    old_descriptions = voting_options.*.description

    (old_descriptions - new_descriptions).each do |description|
      option = VotingOption.agenda_item_id_is(id).description_is(description).first
      option.destroy
    end

    (new_descriptions - old_descriptions ).each do |description|
      VotingOption.create! :agenda_item => self, :description => description
    end
  end
  protected
    # Updated discussion time for a single agenda item
    # protected because we want to call it only from
    # AgendaItem.update_discussion_times
    # or similar methods in children classes (if there will be any)
    def update_discussion_time
      link_regexp =  /^(https?:\/\/)?archives.gentoo.org\/([a-zA-Z-]+)\/(msg_[a-fA-F0-9]+.xml)$/
      uri_match  = link_regexp.match(discussion)
      return unless uri_match

      group = uri_match[2]
      msg = uri_match[3]
      message_info = get_message(group, msg)
      first_date = Time.parse message_info[:date]
      last_date = first_date

      to_visit = []
      visited = Set.new([msg])

      to_visit += message_info[:links]

      until to_visit.empty?
        msg = to_visit.pop()

        next if visited.include? msg
        visited.add msg
        message_info = get_message(group, msg)
        current_date = Time.parse message_info[:date]

        first_date = current_date if first_date > current_date
        last_date = current_date if last_date < current_date
        to_visit += message_info[:links]
      end

      duration = ((last_date - first_date) / 1.day).floor
      first_date = first_date.strftime '%Y.%m.%d'
      last_date = last_date.strftime '%Y.%m.%d'
      self.discussion_time = "From #{first_date} to #{last_date}, #{duration} full days"
      self.save!
    end

    def get_message(group, msg)
      Net::HTTP.start("archives.gentoo.org") { |http|
        resp = http.get("/#{group}/#{msg}?passthru=1")
        doc = REXML::Document.new(resp.body)
        table = REXML::XPath.match(doc, '//table/tr[th=\'Replies:\']/../tr')
        in_replies = false
        reply_links = []
        table.each do |row|
          th = REXML::XPath.first(row, "th")
          if th
            in_replies = (th.text == 'Replies:')
          else
            next unless in_replies
            reply = REXML::XPath.first(row, "ti/uri")
            reply_link = reply.attribute(:link).to_s
            reply_links.push(reply_link)
          end
        end
        date = resp.body.match(/\<\!--X-Date: (.*) --\>/)[1]
        {:date => date, :links => reply_links}
     }
    end

    def timelimits_entered_properly
      regexp = /^\d+:\d+( .*)?$/
      for line in timelimits.split("\n")
        unless line.match regexp
          errors.add(:timelimits, "Line '#{line}' doensn't match '<minutes>:<seconds> <message>'")
        end
      end
    end
end
