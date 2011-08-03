# Do not change those
require 'bundler/capistrano'

set :repository, "git://git.overlays.gentoo.org/proj/council-webapp.git"
set :scm, "git"
set :branch, "master"
set :deploy_subdir, "site"

# Capistrano will ssh to those hosts
role :web, "localhost"
role :app, "localhost"
role :db, "localhost"

# and will use this user name
set :user, 'joszi'

#and will put site in subdirectory of
set :deploy_to, "/home/joszi/app.git/"
