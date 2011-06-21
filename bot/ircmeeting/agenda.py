import json
import urllib
import re

class Agenda(object):

    # Messages
    added_option_msg = "You added new voting option: {}"
    empty_agenda_msg = "Agenda is empty so I can't help you manage meeting (and voting)."
    current_item_msg = "Current agenda item is {}."
    removed_option_msg = "You removed voting option {}: {}"
    voting_already_open_msg = "Voting is already open. You can end it with #endvote."
    voting_open_msg = "Voting started. {}Vote #vote <option number>.\nEnd voting with #endvote."
    voting_close_msg = "Voting closed."
    voting_already_closed_msg = "Voting is already closed. You can start it with #startvote."
    voting_open_so_item_not_changed_msg = "Voting is currently open so I didn't change item. Please #endvote first"
    can_not_vote_msg = "You can not vote or change agenda. Only {} can."
    not_a_number_msg = "Your vote was not recognized as a number. Please retry."
    out_of_range_msg = "Your vote was out of range!"
    vote_confirm_msg = "You voted for #{} - {}"

    # Internal
    _voters     = []
    _votes      = []
    _agenda     = []
    _current_item = 0
    _vote_open  = False

    def __init__(self, conf):
      self.conf = conf

    def get_agenda_item(self):
        if not self.conf.manage_agenda:
          return('')
        if self._current_item < len(self._agenda):
            return str.format(self.current_item_msg, self._agenda[self._current_item][0])
        else:
            return self.empty_agenda_msg

    def next_agenda_item(self):
        if not self.conf.manage_agenda:
          return('')
        if self._vote_open:
            return self.voting_open_so_item_not_changed_msg
        else:
            if (self._current_item + 1) < len(self._agenda):
                self._current_item += 1
            return(self.get_agenda_item())

    def prev_agenda_item(self):
        if not self.conf.manage_agenda:
          return('')
        if self._vote_open:
            return self.voting_open_so_item_not_changed_msg
        else:
            if self._current_item > 0:
                self._current_item -= 1
            return(self.get_agenda_item())

    def start_vote(self):
        if not self.conf.manage_agenda:
          return('')
        if self._vote_open:
            return self.voting_already_open_msg
        self._vote_open = True
        return str.format(self.voting_open_msg, self.options())

    def end_vote(self):
        if not self.conf.manage_agenda:
          return('')
        if self._vote_open:
            self._vote_open = False
            return self.voting_close_msg
        return self.voting_already_closed_msg

    def get_data(self):
        if not self.conf.manage_agenda:
          return('')
        self._voters = self._get_json(self.conf.voters_url)
        self._agenda = self._get_json(self.conf.agenda_url)
        self._votes = { }
        self._voters.sort()
        for i in self._agenda:
            self._votes[i[0]] = { }

    def vote(self, nick, line):
        if not self.conf.manage_agenda:
          return('')
        if not nick in self._voters:
            return str.format(self.can_not_vote_msg, ", ".join(self._voters))

        opt = self._to_voting_option_number(line)
        if opt.__class__ is not int:
          return(opt)

        self._votes[self._agenda[self._current_item][0]][nick] = self._agenda[self._current_item][1][opt]

        users_who_voted = self._votes[self._agenda[self._current_item][0]].keys()
        users_who_voted.sort()

        reply = str.format(self.vote_confirm_msg, opt, self._agenda[self._current_item][1][opt])
        if users_who_voted == self._voters:
          reply += '. ' + self.end_vote()
        return(reply)

    def _get_json(self, url):
        str = urllib.urlopen(url).read()
        str = urllib.unquote(str)
        result = json.loads(str)
        return result

    def _to_voting_option_number(self, line):
        if not line.isdigit():
            return self.not_a_number_msg
        opt = int(line)
        if opt < 0 or opt >= len(self._agenda[self._current_item][1]):
            return self.out_of_range_msg
        return(opt)

    def options(self):
        options_list = self._agenda[self._current_item][1]
        n = len(options_list)
        if n == 0:
          return 'No voting options available.'
        else:
          options = "Available voting options are:\n"
          for i in range(n):
              options += str.format("{}. {}\n", i, options_list[i])
          return options

    def add_option(self, nick, line):
        if not self.conf.manage_agenda:
            return('')
        if not nick in self._voters:
            return str.format(self.can_not_vote_msg, ", ".join(self._voters))
        options_list = self._agenda[self._current_item][1]
        option_text = re.match( ' *?add (.*)', line).group(1)
        options_list.append(option_text)
        return str.format(self.added_option_msg, option_text)

    def remove_option(self, nick, line):
        if not self.conf.manage_agenda:
            return('')
        if not nick in self._voters:
            return str.format(self.can_not_vote_msg, ", ".join(self._voters))

        opt_str = re.match( ' *?remove (.*)', line).group(1)
        opt = self._to_voting_option_number(opt_str)
        if opt.__class__ is not int:
          return(opt)

        option = self._agenda[self._current_item][1].pop(opt)
        return str.format(self.removed_option_msg, str(opt), option)

    def post_result(self):
        if not self.conf.manage_agenda:
          return('')
        data = urllib.quote(json.dumps([self._votes]))
        result_url = str.format(self.conf.result_url,
                      self.conf.voting_results_user,
                      self.conf.voting_results_password)
        urllib.urlopen(result_url, data = data)
