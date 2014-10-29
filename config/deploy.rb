require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm'    # for rvm support. (http://rvm.io)

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
set :branch, 'master'
set :rsync_copy, "rsync --archive --acls --xattrs"
set :rsync_cache, "shared/deploy"
set :shared_paths, ['config/db/production.sqlite3' ,'config/database.yml',
                    'log', 'config/puma.rb', 'config/ldap-control-settings.yml',
                    'public/images/cache_photo', 'tmp']

# Optional settings:
set :user, 'rails'    # Username in the server to SSH to.
#set :port, '30000'     # SSH port number.

task :environment do
  invoke :'rvm:use[ruby-2.1.3@ldap_control]'
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/sockets"]

  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/public/images/cache_photo"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/images/cache_photo"]

  queue! %[mkdir -p "#{deploy_to}/shared/config/db"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config/db"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue! %[touch "#{deploy_to}/shared/config/ldap-control-settings.yml"]
  queue! %[touch "#{deploy_to}/shared/config/puma.rb"]
  queue  %[echo "-----> Be sure to edit 'shared/config/ldap-control-settings.yml'."]
  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
  queue  %[echo "-----> Be sure to edit 'shared/config/puma.rb'."]
end

rsync_stage_dir = "/tmp/ldap_control"

rsync_cache = lambda do
  cache = settings.rsync_cache
  raise TypeError, "Please set rsync_cache." unless cache
  cache = settings.deploy_to + "/" + cache if cache && cache !~ /^\//
  cache
end

namespace :rsync do

  task :create_stage do
    print_status "Create stage..."
    system %[rm -rf #{rsync_stage_dir}; mkdir -p #{rsync_stage_dir} ]
    system %[git archive #{settings.branch} | tar -x -C #{rsync_stage_dir}]
  end

  task :copy_stage do
    print_status "Rsyncing to #{rsync_cache.call}..."
    system %[rsync -r --delete #{rsync_stage_dir}/ #{settings.user}@#{settings.domain}:#{rsync_cache.call}/]
  end

  task :build do
    queue %(echo "-> Copying from cache directory to build path")
    queue %[#{settings.rsync_copy}  "#{rsync_cache.call}/" "."]
  end
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'rsync:create_stage'
    invoke :'rsync:copy_stage'
    invoke :'rsync:build'
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
