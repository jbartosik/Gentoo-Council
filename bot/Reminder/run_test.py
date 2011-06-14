import unittest
from plugin import Reminder
import urllib
import time

class FakeIrc:
  msgs = []

  def sendMsg(self, msg):
    self.msgs.append(msg)

def do_nothing():
  pass
class TestSequenceFunctions(unittest.TestCase):
    def test_ping_with_newer_stamp(self):
      logger = FakeIrc()
      testee = Reminder(logger, sleep = 0)
      testee.get_data = do_nothing
      testee.data = {"users":["nick1","nick2"],"remind_time":u"Wed Jun 08 20:15:04 2011","message":u"Test message"}
      time.sleep(1)
      assert(len(logger.msgs) == 2)
      for i in range(2):
        assert(logger.msgs[i].command == 'PRIVMSG')
        assert(logger.msgs[i].args[0] == 'nick' + str(i+1))
        assert(logger.msgs[i].args[1] == u"Test message")

if __name__ == '__main__':
    unittest.main()
