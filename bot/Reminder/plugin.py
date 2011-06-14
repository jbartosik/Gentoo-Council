###
# Copyright (c) 2011, Joachim Bartosik
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright notice,
#     this list of conditions, and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions, and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#   * Neither the name of the author of this software nor the name of
#     contributors to this software may be used to endorse or promote products
#     derived from this software without specific prior written consent.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

###

import supybot.utils as utils
from supybot.commands import *
import supybot.plugins as plugins
import supybot.ircutils as ircutils
import supybot.callbacks as callbacks

import time
import thread
import urllib
import json
import supybot.ircmsgs as ircmsgs

class Reminder(callbacks.Plugin):
    def __init__(self, irc, sleep = 10):
        self.__parent = super(Reminder, self)
        self.__parent.__init__(irc)
        self.irc = irc
        self.sleep = sleep
        self.source_url = 'http://localhost:3000/agendas/reminders'
        self.last_remind_time = time.gmtime(0)
        self.data = {}
        thread.start_new_thread(self.reminding_loop, ())

    def get_data(self):
        try:
            raw = urllib.urlopen(self.source_url).read()
            raw = urllib.unquote(raw)
            self.data = json.loads(raw)
        except:
            self.data = {}

    def data_valid(self):
        if (self.data.__class__ is not dict):
            return False

        if 'users' not in self.data.keys():
            return False
        if 'remind_time' not in self.data.keys():
            return False
        if 'message' not in self.data.keys():
            return False

        if not self.data['users'].__class__ is list:
            return False
        if not self.data['remind_time'].__class__ is unicode:
            return False
        if not self.data['message'].__class__ is unicode:
            return False

        return True

    def it_is_time_to_send(self):
        try:
            reminder_time = time.strptime(self.data['remind_time'])
        except:
            return False

        if reminder_time > self.last_remind_time:
            self.last_remind_time = reminder_time
            return True
        return False

    def reminding_loop(self):
        while True:
            time.sleep(self.sleep)

            self.get_data()
            if not self.data_valid():
                continue
            if not self.it_is_time_to_send():
                continue

            msg = self.data['message']

            for nick in self.data['users']:
                self.irc.sendMsg(ircmsgs.privmsg(str(nick), str(msg)))

Class = Reminder
