# About the project
This project has three parts:

 * Website written in Ruby (using Rails and Hobo). This site helps to prepare
    meetings, collect ideas and feedback from community.
 * Modified MeetBot (MeetBot is supybot plugin). This plugin handles meetings.
    You can use

        #commands

    to list available commands and

        #command <command>

    to view help for each command.

 * Reminder plugin. This supybot plugin pulls reminder information from
    the website and sends messages to all council members to remind them about
    upcoming meeting.

## Copyright

### Website
Website is distributed under terms of AGPL3 or later.

### Modified MeetBot plugin
The plugin is distributed on the same terms as original MeetBot.

### Reminder plugin
Reminder plugin is distributed under BSD-style license (you can do with it
anything you want but you must use the same license and don't use my name for
advertising).

# Usage
What you can do depends on your role. You can be guest or a registered user.
Once you register administrators can give you administrator and council member
roles.

### Guest
As guest you can only view:

 * Current and past agendas
 * Items for agendas
 * Voting results
 * Meeting summaries approved by council
 * Council attendance

### Registered user
Once you register you can do everything a guest can and:

 * Suggest items for council
 * Participate in community vote

### Council member
When administrator will give you a council member role you will be able to do
everything a regular registered user can and:

 * Change agendas states (available states are open, submissions closed, meeting\_ongoing, old)
 * Add suggested items to agenda
 * Reject suggested items
 * Vote during meetings (IRC bot handles voting)

### Administrator
As administrator you can manage users - give them new roles and take away old roles.

## Configuration
The application users following (untracked) configuration files:

 * site/config/bot.yml
 * site/config/council\_term.yml
 * site/config/database.yml
 * site/config/reminders.yml

database.yml is regular rails database configuration file. Samples for other
configuration files are available in

    site/doc/sample_configs/

directory.

# Installation
## Manual
1. Install bundler, rails, git and database you want to use.
2. Obtain sources

        git clone git://github.com/ahenobarbi/Gentoo-Council.git

3. Go to directory with webapp (site/ subdirectory inside directory created in
   the previous step) sources and install required gems

        bundle install

4. Configure application
5. Start server by running the following command

        bundle exec rails server

## With passenger
1. Clone git repository
2. Configure install and configure MySQL, Apache, passenger (sample vhost config
in site/doc/sample\_configs/ ). Remember that the web app is in

    $(repo\_directory)/site

3. In

    $(repo\_directory)/site

run

    bundle install
    bundle exec rails g hobo:rapid
    touch tmp/restart.txt

4. Check if everything works fine.

If you want to use capistrano I can write instructions for that.

## Use capistrano
1. Install capistrano and git on your machine
2. Clone repository
2. Run

    cd /path/to/your/clone/site && capify .

3. Customise

    config/deploy.rb

see site/doc/sample\_configs/deploy.rb for reference.

use attached file as base.

4. Install git and bundler on host on which you will deploy
5. Configure passenger on target host
6. Run (on you development machine)

    cap deploy:setup
    cap deploy

7. (reason why you might like to go through previous steps) When you want to
update application just run

   cap deploy

#How to use supybot plugins
1. Install supybot
2. Get those sources
3. Copy or link bot/MeetBot and bot/Reminder directories to supybot plugins
    directory. On my system it's

        /usr/lib64/python2.7/site-packages/supybot/plugins/

4. Copy or link bot/ircmeeting to some directory you have in your PYTHONPATH
    Or to directory fromwhich you will run supypot.
5. Create directory for supybot config and logs.
6. In this directory run

        supybot-wizard

    it will create *.conf file.
7. Run

    supybot file_created_in_previous steps
