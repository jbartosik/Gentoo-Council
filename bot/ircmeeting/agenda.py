import json
import urllib

class Agenda(object):

    # Messages
    empty_agenda_msg = "Agenda is empty so I can't help you manage meeting (and voting)."
    current_item_msg = "Current agenda item is {}."
    voting_already_open_msg = "Voting is already open. You can end it with #endvote."
    voting_open_msg = "Voting started. Your choices are: {} Vote #vote <option number>.\n End voting with #endvote."
    voting_close_msg = "Voting is closed."
    voting_already_closed_msg = "Voting is already closed. You can start it with #startvote."
    voting_open_so_item_not_changed_msg = "Voting is currently open so I didn't change item. Please #endvote first"
    can_not_vote_msg = "You can not vote. Only {} can vote"
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
        if self._current_item < len(self._agenda):
            return str.format(self.current_item_msg, self._agenda[self._current_item][0])
        else:
            return self.empty_agenda_msg

    def next_agenda_item(self):
        if self._vote_open:
            return voting_open_so_item_not_changed_msg
        else:
            if (self._current_item + 1) < len(self._agenda):
                self._current_item += 1
            return(self.get_agenda_item())

    def prev_agenda_item(self):
        if self._vote_open:
            return voting_open_so_item_not_changed_msg
        else:
            if self._current_item > 0:
                self._current_item -= 1
            return(self.get_agenda_item())

    def start_vote(self):
        if self._vote_open:
            return self.voting_already_open_msg
        self._vote_open = True
        options = "\n"
        for i in range(len(self._agenda[self._current_item][1])):
            options += str.format("{}. {}\n", i, self._agenda[self._current_item][1][i])
        return str.format(self.voting_open_msg, options)

    def end_vote(self):
        if self._vote_open:
            self._vote_open = False
            return self.voting_already_closed_msg
        return voting_close_msg

    def get_data(self):
        self._voters = self._get_json(self.conf.voters_url)
        self._agenda = self._get_json(self.conf.agenda_url)
        self._votes = { }
        for i in self._agenda:
            self._votes[i[0]] = { }

    def vote(self, nick, line):
        if not nick in self._voters:
            return str.format(self.can_not_vote_msg, ", ".join(self._voters))
        if not line.isdigit():
            return self.not_a_number_msg

        opt = int(line)

        if opt < 0 or opt >= len(self._agenda[self._current_item][1]):
            return self.out_of_range_msg

        self._votes[self._agenda[self._current_item][0]][nick] = self._agenda[self._current_item][1][opt]
        return str.format(self.vote_confirm_msg, opt, self._agenda[self._current_item][1][opt])

    def _get_json(self, url):
        str = urllib.urlopen(url).read()
        str = urllib.unquote(str)
        result = json.loads(str)
        return result

    def post_result(self):
        data = urllib.quote(json.dumps([self._votes]))
        result_url = str.format(self.conf.result_url,
                      self.conf.voting_results_user,
                      self.conf.voting_results_password)
        urllib.urlopen(result_url, data = data)
