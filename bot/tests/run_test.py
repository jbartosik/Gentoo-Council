# Richard Darst, 2009
# Joachim Bartosik, 2011

import glob
import os
import re
import shutil
import sys
import tempfile
import time
import threading
import unittest

os.environ['MEETBOT_RUNNING_TESTS'] = '1'
import ircmeeting.meeting as meeting
import ircmeeting.writers as writers

import test_meeting

running_tests = True

def process_meeting(contents, extraConfig={}, dontSave=True,
                    filename='/dev/null'):
    """Take a test script, return Meeting object of that meeting.

    To access the results (a dict keyed by extensions), use M.save(),
    with M being the return of this function.
    """
    return meeting.process_meeting(contents=contents,
                                channel="#none",  filename=filename,
                                dontSave=dontSave, safeMode=False,
                                extraConfig=extraConfig)

class MeetBotTest(unittest.TestCase):

    def test_replay(self):
        """Replay of a meeting, using 'meeting.py replay'.
        """
        old_argv = sys.argv[:]
        sys.argv[1:] = ["replay", "test-script-1.log.txt"]
        sys.path.insert(0, "../ircmeeting")
        try:
            gbls = {"__name__":"__main__",
                    "__file__":"../ircmeeting/meeting.py"}
            execfile("../ircmeeting/meeting.py", gbls)
            assert "M" in gbls, "M object not in globals: did it run?"
        finally:
            del sys.path[0]
            sys.argv[:] = old_argv

    def test_supybottests(self):
        """Test by sending input to supybot, check responses.

        Uses the external supybot-test command.  Unfortunantly, that
        doesn't have a useful status code, so I need to parse the
        output.
        """

        links_to_remove = []
        for file in ["MeetBot", "ircmeeting"]:
          if not os.path.exists(file):
            os.symlink("../" + file , file)
            links_to_remove.append(file)

        sys.path.insert(0, ".")
        try:
            output = os.popen("supybot-test ./MeetBot 2>&1").read()
            assert 'FAILED' not in output, "supybot-based tests failed."
            assert '\nOK\n'     in output, "supybot-based tests failed."
        finally:
            for link in links_to_remove:
              os.unlink(link)
            del sys.path[0]

    trivial_contents = """
    10:10:10 <x> #startmeeting
    10:10:10 <x> blah
    10:10:10 <x> #endmeeting
    """

    full_writer_map = {
        '.log.txt':     writers.TextLog,
        '.log.1.html':  writers.HTMLlog1,
        '.log.html':    writers.HTMLlog2,
        '.1.html':      writers.HTML1,
        '.html':        writers.HTML2,
        '.rst':         writers.ReST,
        '.rst.html':    writers.HTMLfromReST,
        '.txt':         writers.Text,
        '.mw':          writers.MediaWiki,
        '.pmw':         writers.PmWiki,
        '.tmp.txt|template=+template.txt':   writers.Template,
        '.tmp.html|template=+template.html': writers.Template,
        }

    def M_trivial(self, contents=None, extraConfig={}):
        """Convenience wrapper to process_meeting.
        """
        if contents is None:
            contents = self.trivial_contents
        return process_meeting(contents=contents,
                               extraConfig=extraConfig)

    def test_script_1(self):
        """Run test-script-1.log.txt through the processor.

        - Check all writers
        - Check actual file writing.
        """
        tmpdir = tempfile.mkdtemp(prefix='test-meetbot')
        try:
            process_meeting(contents=file('test-script-1.log.txt').read(),
                            filename=os.path.join(tmpdir, 'meeting'),
                            dontSave=False,
                            extraConfig={'writer_map':self.full_writer_map,
                                         })
            # Test every extension in the full_writer_map to make sure
            # it was written.
            for extension in self.full_writer_map:
                ext = re.search(r'^\.(.*?)($|\|)', extension).group(1)
                files = glob.glob(os.path.join(tmpdir, 'meeting.'+ext))
                assert len(files) > 0, \
                       "Extension did not produce output: '%s'"%extension
        finally:
            shutil.rmtree(tmpdir)

    #def test_script_3(self):
    #   process_meeting(contents=file('test-script-3.log.txt').read(),
    #                   extraConfig={'writer_map':self.full_writer_map})

    all_commands_test_contents = test_meeting.get_test_script('all_commands.txt')

    def test_contents_test2(self):
        """Ensure that certain input lines do appear in the output.

        This test ensures that the input to certain commands does
        appear in the output.
        """
        M = process_meeting(contents=self.all_commands_test_contents,
                            extraConfig={'writer_map':self.full_writer_map})
        results = M.save()
        for name, output in results.iteritems():
            self.assert_('h6k4orkac' in output, "Topic failed for %s"%name)
            self.assert_('blaoulrao' in output, "Info failed for %s"%name)
            self.assert_('alrkkcao4' in output, "Idea failed for %s"%name)
            self.assert_('ntoircoa5' in output, "Help failed for %s"%name)
            self.assert_('http://bnatorkcao.net' in output,
                                                  "Link(1) failed for %s"%name)
            self.assert_('kroacaonteu' in output, "Link(2) failed for %s"%name)
            self.assert_('http://jrotjkor.net' in output,
                                        "Link detection(1) failed for %s"%name)
            self.assert_('krotroun' in output,
                                        "Link detection(2) failed for %s"%name)
            self.assert_('xrceoukrc' in output, "Action failed for %s"%name)
            self.assert_('okbtrokr' in output, "Nick failed for %s"%name)

            # Things which should only appear or not appear in the
            # notes (not the logs):
            if 'log' not in name:
                self.assert_( 'ckmorkont' not in output,
                              "Undo failed for %s"%name)
                self.assert_('topic_doeschange' in output,
                             "Chair changing topic failed for %s"%name)
                self.assert_('topic_doesntchange' not in output,
                             "Non-chair not changing topic failed for %s"%name)
                self.assert_('topic_doesnt2change' not in output,
                            "Un-chaired was able to chang topic for %s"%name)

    #def test_contents_test(self):
    #    contents = open('test-script-3.log.txt').read()
    #    M = process_meeting(contents=file('test-script-3.log.txt').read(),
    #                        extraConfig={'writer_map':self.full_writer_map})
    #    results = M.save()
    #    for line in contents.split('\n'):
    #        m = re.search(r'#(\w+)\s+(.*)', line)
    #        if not m:
    #            continue
    #        type_ = m.group(1)
    #        text = m.group(2)
    #        text = re.sub('[^\w]+', '', text).lower()
    #
    #        m2 = re.search(t2, re.sub(r'[^\w\n]', '', results['.txt']))
    #        import fitz.interactnow
    #        print m.groups()

    def test_actionNickMatching(self):
        """Test properly detect nicknames in lines

        This checks the 'Action items, per person' list to make sure
        that the nick matching is limited to full words.  For example,
        the nick 'jon' will no longer be assigned lines containing
        'jonathan'.
        """

        script = open('test_scripts/actionNickMatching.txt').read()

        M = process_meeting(script)
        results = M.save()['.html']
        # This regular expression is:
        # \bsomenick\b   - the nick in a single word
        # (?! \()        - without " (" following it... to not match
        #                  the "People present" section.
        assert not re.search(r'\bsomenick\b(?! \()',
                         results, re.IGNORECASE), \
                         "Nick full-word matching failed"

    def test_urlMatching(self):
        """Test properly detection of URLs in lines
        """
        script =  open('test_scripts/urlMatching.txt').read()

        M = process_meeting(script)
        results = M.save()['.html']
        assert re.search(r'prefix.*href.*http://site1.com.*suffix',
                         results), "URL missing 1"
        assert re.search(r'href.*http://site2.com.*suffix',
                         results), "URL missing 2"
        assert re.search(r'href.*ftp://ftpsite1.com.*suffix',
                         results), "URL missing 3"
        assert re.search(r'prefix.*href.*ftp://ftpsite2.com.*suffix',
                         results), "URL missing 4"
        assert re.search(r'href.*mailto://a@mail.com.*suffix',
                         results), "URL missing 5"

    def t_css(self):
        """Runs all CSS-related tests.
        """
        self.test_css_embed()
        self.test_css_noembed()
        self.test_css_file_embed()
        self.test_css_file()
        self.test_css_none()
    def test_css_embed(self):
        extraConfig={ }
        results = self.M_trivial(extraConfig={}).save()
        self.assert_('<link rel="stylesheet" ' not in results['.html'])
        self.assert_('body {'                      in results['.html'])
        self.assert_('<link rel="stylesheet" ' not in results['.log.html'])
        self.assert_('body {'                      in results['.log.html'])
    def test_css_noembed(self):
        extraConfig={'cssEmbed_minutes':False,
                     'cssEmbed_log':False,}
        M = self.M_trivial(extraConfig=extraConfig)
        results = M.save()
        self.assert_('<link rel="stylesheet" '     in results['.html'])
        self.assert_('body {'                  not in results['.html'])
        self.assert_('<link rel="stylesheet" '     in results['.log.html'])
        self.assert_('body {'                  not in results['.log.html'])
    def test_css_file(self):
        tmpf = tempfile.NamedTemporaryFile()
        magic_string = '546uorck6o45tuo6'
        tmpf.write(magic_string)
        tmpf.flush()
        extraConfig={'cssFile_minutes':  tmpf.name,
                     'cssFile_log':      tmpf.name,}
        M = self.M_trivial(extraConfig=extraConfig)
        results = M.save()
        self.assert_('<link rel="stylesheet" ' not in results['.html'])
        self.assert_(magic_string                  in results['.html'])
        self.assert_('<link rel="stylesheet" ' not in results['.log.html'])
        self.assert_(magic_string                  in results['.log.html'])
    def test_css_file_embed(self):
        tmpf = tempfile.NamedTemporaryFile()
        magic_string = '546uorck6o45tuo6'
        tmpf.write(magic_string)
        tmpf.flush()
        extraConfig={'cssFile_minutes':  tmpf.name,
                     'cssFile_log':      tmpf.name,
                     'cssEmbed_minutes': False,
                     'cssEmbed_log':     False,}
        M = self.M_trivial(extraConfig=extraConfig)
        results = M.save()
        self.assert_('<link rel="stylesheet" '     in results['.html'])
        self.assert_(tmpf.name                     in results['.html'])
        self.assert_('<link rel="stylesheet" '     in results['.log.html'])
        self.assert_(tmpf.name                     in results['.log.html'])
    def test_css_none(self):
        tmpf = tempfile.NamedTemporaryFile()
        magic_string = '546uorck6o45tuo6'
        tmpf.write(magic_string)
        tmpf.flush()
        extraConfig={'cssFile_minutes':  'none',
                     'cssFile_log':      'none',}
        M = self.M_trivial(extraConfig=extraConfig)
        results = M.save()
        self.assert_('<link rel="stylesheet" ' not in results['.html'])
        self.assert_('<style type="text/css" ' not in results['.html'])
        self.assert_('<link rel="stylesheet" ' not in results['.log.html'])
        self.assert_('<style type="text/css" ' not in results['.log.html'])

    def test_filenamevars(self):
        def getM(fnamepattern):
            M = meeting.Meeting(channel='somechannel',
                                network='somenetwork',
                                owner='nobody',
                     extraConfig={'filenamePattern':fnamepattern})
            M.addline('nobody', '#startmeeting')
            return M
        # Test the %(channel)s and %(network)s commands in supybot.
        M = getM('%(channel)s-%(network)s')
        assert M.config.filename().endswith('somechannel-somenetwork'), \
               "Filename not as expected: "+M.config.filename()
        # Test dates in filenames
        M = getM('%(channel)s-%%F')
        import time
        assert M.config.filename().endswith(time.strftime('somechannel-%F')),\
               "Filename not as expected: "+M.config.filename()
        # Test #meetingname in filenames
        M = getM('%(channel)s-%(meetingname)s')
        M.addline('nobody', '#meetingname blah1234')
        assert M.config.filename().endswith('somechannel-blah1234'),\
               "Filename not as expected: "+M.config.filename()

    def get_simple_agenda_test(self):
        test = test_meeting.TestMeeting()
        test.set_voters(['x', 'z'])
        test.set_agenda([['first item', ['opt1', 'opt2'], ''], ['second item', [], ''], ['third item', [], '']])
        test.M.config.manage_agenda = False

        test.answer_should_match("20:13:50 <x> #startmeeting",
        "Meeting started .*\nUseful Commands: #action #agreed #help #info #idea #link #topic.\n")
        test.M.config.manage_agenda = True

        return(test)

    def test_message_answer_tests(self):
        files = ['agenda_item_changing', 'agenda_option_listing',
                  'agenda_option_adding', 'agenda_option_removing',
                  'close_voting_after_last_vote']
        for file in files:
            test = self.get_simple_agenda_test()
            test.check_responses_from_json_file(file)

    def test_agenda_voting(self):
        test = self.get_simple_agenda_test()
        test.M.config.agenda._voters.append('t')
        test.check_responses_from_json_file('agenda_voting')
        test.M.config.manage_agenda = False
        test.answer_should_match('20:13:50 <x> #endmeeting', 'Meeting ended ' +\
                                  '.*\nMinutes:.*\nMinutes \(text\):.*\nLog:.*')
        assert(test.votes() == {'first item': {u'x': 'opt2', u'z': 'opt1'}, 'second item': {}, 'third item': {}})


    def test_agenda_time_limit_adding(self):
        test = self.get_simple_agenda_test()
        test.answer_should_match('20:13:50 <x> #timelimit', test.M.do_timelimit.__doc__)
        test.answer_should_match('20:13:50 <x> #timelimit add 0:1 some other message',
                                  'Added "some other message" reminder in 0:1')
        test.answer_should_match('20:13:50 <x> #timelimit add 1:0 some message',
                                  'Added "some message" reminder in 1:0')
        time.sleep(2)
        last_message = test.log[-1]
        assert(last_message == 'some other message')
        reminders = test.M.config.agenda.reminders
        assert(len(reminders) == 2)
        for reminder in reminders.values():
          assert(reminder.__class__ == threading._Timer)

        test.process('20:13:50 <x> #nextitem')

    def test_agenda_time_limit_removing_when_changing_item(self):
        test = self.get_simple_agenda_test()

        test.process('20:13:50 <x> #timelimit add 0:1 message')
        assert(len(test.M.config.agenda.reminders) == 1)
        test.process('20:13:50 <x> #nextitem')
        assert(len(test.M.config.agenda.reminders) == 0)
        test.process('20:13:50 <x> #timelimit add 0:1 message')
        assert(len(test.M.config.agenda.reminders) == 1)
        test.process('20:13:50 <x> #previtem')
        assert(len(test.M.config.agenda.reminders) == 0)

    def test_agenda_time_limit_manual_removing(self):
        test = self.get_simple_agenda_test()

        test.process('20:13:50 <x> #timelimit add 0:1 message')
        test.process('20:13:50 <x> #timelimit add 0:1 other message')
        keys = test.M.config.agenda.reminders.keys()
        keys.sort()
        assert(keys == ['message', 'other message'])

        test.answer_should_match('20:13:50 <x> #timelimit remove other message', 'Reminder "other message" removed')
        keys = test.M.config.agenda.reminders.keys()
        assert(keys == ['message'])

    def test_agenda_time_limit_listing(self):
        test = self.get_simple_agenda_test()
        test.process('20:13:50 <x> #timelimit add 0:1 message')
        test.process('20:13:50 <x> #timelimit add 0:1 other message')
        test.process('20:13:50 <x> #timelimit add 0:1 yet another message')
        keys = test.M.config.agenda.reminders.keys()
        test.answer_should_match('20:13:50 <x> #timelimit list',
                                  'Set reminders: "' + '", "'.join(keys) + '"')

    def test_preset_agenda_time_limits(self):
        test = self.get_simple_agenda_test()
        test.M.config.agenda._agenda[0][2] = '1:0 message'
        test.M.config.agenda._agenda[1][2] = '1:0 another message\n0:10 some other message'

        test.process('20:13:50 <x> #nextitem')
        keys = test.M.config.agenda.reminders.keys()
        keys.sort()
        assert(keys == ['another message', 'some other message'])

        test.process('20:13:50 <x> #previtem')
        keys = test.M.config.agenda.reminders.keys()
        keys.sort()
        assert(keys == ['message'])

        test.process('20:13:50 <x> #nextitem')

    def test_multiple_reminders(self):
        test = self.get_simple_agenda_test()
        test.process('20:13:50 <x> #timelimit add 0:1 message')
        test.process('20:13:50 <x> #timelimit add 0:2 other message')
        test.process('20:13:50 <x> #timelimit add 0:3 yet another message')
        test.log = []
        time.sleep(4)
        expected_messages = ['message', 'other message', 'yet another message']
        messages_match = (expected_messages == test.log)
        error_msg = 'Received messages ' + str(test.log) + \
                    ' didn\'t match expected ' + str(expected_messages)
        assert messages_match, error_msg

    def test_command_help(self):
        test = self.get_simple_agenda_test()
        commands = ['startmeeting', 'startvote', 'vote', 'endvote',
                    'nextitem', 'previtem', 'changeitem', 'option',
                    'timelimit', 'endmeeting']
        for command in commands:
          desc = getattr(test.M, 'do_' + command).__doc__
          if desc is None:
            desc = ''
          test.answer_should_match('20:13:50 <x> #command ' + command, desc)

if __name__ == '__main__':
    os.chdir(os.path.join(os.path.dirname(__file__), '.'))

    if len(sys.argv) <= 1:
        unittest.main()
    else:
        for testname in sys.argv[1:]:
            print testname
            if hasattr(MeetBotTest, testname):
                MeetBotTest(methodName=testname).debug()
            else:
                MeetBotTest(methodName='test_'+testname).debug()
