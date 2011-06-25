import json
import threading
import urllib
import re

class MessageSender:
  def __init__(self, irc, message):
    self.irc = irc
    self.message = message
  def send_message(self):
    self.irc.reply(self.message)

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
    not_a_number_msg = "Your choice was not recognized as a number. Please retry."
    out_of_range_msg = "Your choice was out of range!"
    vote_confirm_msg = "You voted for #{} - {}"
    timelimit_added_msg = 'Added "{}" reminder in {}:{}'
    timelimit_list_msg = 'Set reminders: "{}"'
    timelimit_removed_msg = 'Reminder "{}" removed'
    timelimit_missing_msg = 'No such reminder "{}"'

    # Internal
    _voters     = []
    _votes      = []
    _agenda     = []
    _current_item = 0
    _vote_open  = False

    def __init__(self, conf):
      self.conf = conf
      self.reminders = {}

    def get_agenda_item(self):
        if not self.conf.manage_agenda:
          return('')
        if self._current_item < len(self._agenda):
            return str.format(self.current_item_msg, self._agenda[self._current_item][0])
        else:
            return self.empty_agenda_msg

    def _swich_agenda_item_to(self, new_item, irc):
      self._current_item = new_item
      for reminder in self.reminders.values():
        reminder.cancel()
      self.reminders = {}
      for line in self._agenda[self._current_item][2].split('\n'):
        match = re.match( '([0-9]+):([0-9]+) (.*)', line)
        if match:
          self.add_timelimit(int(match.group(1)), int(match.group(2)),
                                match.group(3), irc)
      self._agenda[self._current_item][2] = ''

    def next_agenda_item(self, irc):
        if not self.conf.manage_agenda:
          return('')
        if self._vote_open:
            return self.voting_open_so_item_not_changed_msg
        else:
            if (self._current_item + 1) < len(self._agenda):
                self._swich_agenda_item_to(self._current_item + 1, irc)
            return(self.get_agenda_item())

    def prev_agenda_item(self, irc):
        if not self.conf.manage_agenda:
          return('')
        if self._vote_open:
            return self.voting_open_so_item_not_changed_msg
        else:
            if self._current_item > 0:
                self._swich_agenda_item_to(self._current_item - 1, irc)
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

    def _to_number(self, line, upper_limit):
        if not line.isdigit():
            return self.not_a_number_msg
        opt = int(line)
        if opt < 0 or opt >= upper_limit:
            return self.out_of_range_msg
        return(opt)

    def _to_voting_option_number(self, line):
        return(self._to_number(line, len(self._agenda[self._current_item][1])))

    def _to_agenda_item_number(self, line):
        return(self._to_number(line, len(self._agenda)))

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

    def change_agenda_item(self, line):
        if not self.conf.manage_agenda:
          return('')
        if self._vote_open:
            return self.voting_open_so_item_not_changed_msg
        opt = self._to_agenda_item_number(line)
        if opt.__class__ is not int:
          return(opt)
        self._current_item = opt
        return(self.get_agenda_item())

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

    def add_timelimit(self, minutes, seconds, message, irc):
      sender = MessageSender(irc, message)
      reminder = (threading.Timer(60*minutes + seconds, sender.send_message))
      self.reminders[message] = reminder
      reminder.start()
      result = str.format(self.timelimit_added_msg, message, minutes, seconds)
      return(result)

    def list_timielimits(self):
      keys = self.reminders.keys()
      keys_str = '", "'.join(keys)
      result = str.format(self.timelimit_list_msg, keys_str)
      return(result)

    def remove_timelimit(self, message):
      if message in self.reminders:
        timer = self.reminders.pop(message)
        timer.cancel()
        result = str.format(self.timelimit_removed_msg, message)
      else:
         result = str.format(self.timelimit_missing_msg, message)
      return(result)

    def post_result(self):
        if not self.conf.manage_agenda:
          return('')
        data = urllib.quote(json.dumps([self._votes]))
        result_url = str.format(self.conf.result_url,
                      self.conf.voting_results_user,
                      self.conf.voting_results_password)
        urllib.urlopen(result_url, data = data)
