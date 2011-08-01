import ircmeeting.meeting as meeting
import ircmeeting.writers as writers
import inspect
import json
import os
import re
import time
class TestMeeting:
  logline_re = re.compile(r'\[?([0-9: ]*)\]? *<[@+]?([^>]+)> *(.*)')
  loglineAction_re = re.compile(r'\[?([0-9: ]*)\]? *\* *([^ ]+) *(.*)')
  log = []

  def __init__(self):
    self.M = meeting.process_meeting(contents = '',
                                channel = "#none",  filename = '/dev/null',
                                dontSave = True, safeMode = False,
                                extraConfig = {})
    self.M._sendReply = lambda x: self.log.append(x)
    self.M.starttime = time.gmtime(0)

  def set_voters(self, voters):
    self.M.config.agenda._voters = voters

  def set_agenda(self, agenda):
    self.M.config.agenda._agenda = agenda
    self.M.config.agenda._votes = { }
    for i in agenda:
      self.M.config.agenda._votes[i[0]] = { }


  def parse_time(self, time_):
    try: return time.strptime(time_, "%H:%M:%S")
    except ValueError: pass
    try: return time.strptime(time_, "%H:%M")
    except ValueError: pass

  def process(self, content):
    for line in content.split('\n'):
      # match regular spoken lines:
      m = self.logline_re.match(line)
      if m:
        time_ = self.parse_time(m.group(1).strip())
        nick = m.group(2).strip()
        line = m.group(3).strip()
        if self.M.owner is None:
            self.M.owner = nick ; self.M.chairs = {nick:True}
        self.M.addline(nick, line, time_=time_)
      # match /me lines
      self.m = self.loglineAction_re.match(line)
      if m:
          time_ = self.parse_time(m.group(1).strip())
          nick = m.group(2).strip()
          line = m.group(3).strip()
          self.M.addline(nick, "ACTION "+line, time_=time_)

  def check_responses_from_json_file(self, file):
    json_file_name  = file + ".json"
    json_string     = get_test_script(json_file_name)
    json_data       = json.loads(json_string)
    prefix          = "(in " + file + ")"
    for line in json_data:
      if line.__class__ in [str, unicode]:
        self.process(line)
      elif (line.__class__ in [list, tuple]) and (len(line) == 2):
        self.answer_should_match(line[0], line[1], prefix)
      else:
        error_msg = "In file " + file + "Each item in test case must " +\
                    "be string, unicode string, list of length 2. Item `" +\
                    str(line) + "` doesn't fulfill those requirements."
        raise AssertionError(error_msg)

  def answer_should_match(self, line, answer_regexp, prefix = ''):
    self.log = []
    self.process(line)
    answer = '\n'.join(self.log)
    error_msg = prefix + "Answer for:\n\t'" + line + "'\n was \n\t'" + answer +\
                "'\ndid not match regexp\n\t'" + answer_regexp + "'"
    answer_matches = re.match(answer_regexp, answer)
    assert answer_matches, error_msg

  def votes(self):
    return(self.M.config.agenda._votes)

def get_test_script(test_script_file_name):
    this_file_path    = inspect.getfile(inspect.currentframe())
    this_dir_path     = os.path.dirname(this_file_path)
    test_script_path  = os.path.join(this_dir_path, 'test_scripts', test_script_file_name)
    test_script_file  = open(test_script_path)
    return test_script_file.read()
