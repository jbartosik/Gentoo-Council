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

module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /the login page/
      user_login_path

    when /the signup page/
      user_signup_path

    when /the current agenda page/
      agenda_path(Agenda.current)

    when /the first suggested agenda page/
      agenda_item_path(AgendaItem.first(:conditions => {:agenda_id => nil}))

    when /the voters page/
      voters_path

    when /the current items page/
      current_items_path

    when /the "([^\"]*)" show page/
      user_path(User.find_by_name($1))

    when /([1-9]*)th agenda page/
      agenda_path(Agenda.find $1)

    when /agenda item number ([1-9]*) show page/
      agenda_item_path($1)

    when /newest agenda item page/
      agenda_item_path(AgendaItem.last)

    when /newest agenda item edit page/
      edit_agenda_item_path(AgendaItem.last)

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
