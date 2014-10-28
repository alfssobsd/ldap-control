require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm'    # for rvm support. (http://rvm.io)
require "mina/rsync"

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

# set :domains, %w[host1 host2 host3]
#
# desc "Deploy to all servers"
# task :deploy_all do
#   isolate do
#     domains.each do |domain|
#       set :domain, domain
#       invoke :deploy
#       run!
#     end
#   end
# end

set :domain, 'ldap-01.vuaro.ru'
set :deploy_to, '/srv/app/ldap_control'
# set :repository, '.'
set :branch, 'master'
set :rsync_options, %w[--recursive --delete --delete-excluded --exclude .git*]
set :rsync_stage, '/tmp/ldap_control'
set :shared_paths, ['config/database.yml', 'log', 'config/puma.rb', 'config/ldap-control-settings.yml']

# Optional settings:
set :user, 'rails'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use[ruby-2.1.3@ldap_control]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue! %[touch "#{deploy_to}/shared/config/ldap-control-settings.yml"]
  queue! %[touch "#{deploy_to}/shared/config/puma.rb"]
  queue  %[echo "-----> Be sure to edit 'shared/config/ldap-control-settings.yml'."]
  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
  queue  %[echo "-----> Be sure to edit 'shared/config/puma.rb'."]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    system %[mkdir -p #{rsync_stage}]
    system %[rsync --recursive --delete . #{rsync_stage}]
    invoke "rsync:deploy"
    invoke :'bundle:install'
    invoke :'deploy:link_shared_paths'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
