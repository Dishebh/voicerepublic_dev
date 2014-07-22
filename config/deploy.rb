# config valid only for Capistrano 3.1
lock '3.1.0'

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '1.9.3-p448' # i think this option is obsolete
#set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
#set :rbenv_map_bins, %w{rake gem bundle ruby rails}
#set :rbenv_roles, :all # default value
set :rbenv_ruby_version, "1.9.3-p448"

set :application, 'voice_republic'
set :repo_url, 'git@github.com:munen/voicerepublic_dev.git'

set :ssh_options, { forward_agent: true }

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/app/app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
#set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{ config/database.yml 
                       config/private_pub.yml
                       config/settings.local.yml }

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache
#                      tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{ log tmp/pids public/system }

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rails_env, 'production'

namespace :deploy do

  after :started do
    who = %x[whoami;hostname].split.join('@')
    slack "#{who} STARTED a deployment of "+
          "#{fetch(:application)} to #{fetch(:stage)}"
  end

  after :finished do
    who = %x[whoami;hostname].split.join('@')
    slack "#{who} FINISHED a deployment of "+
          "#{fetch(:application)} to #{fetch(:stage)}"
  end
  
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      execute "RAILS_ENV=#{fetch(:rails_env)} $HOME/bin/unicorn_wrapper restart"
      # Kill all delayed jobs and leave the respawning to monit.
      execute "pkill -f delayed_job; true"
      # Will deliberately keep private_pub and rtmpd running
      # since we'll almost never have to change their code base
      # resp. config. If a restart is nescesarry use the web
      # interface of monit to restart those processes.
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end 
   end
  end

end

def slack(message)
  url = "https://voicerepublic.slack.com/services/hooks/incoming-webhook"+
        "?token=VtybT1KujQ6EKstsIEjfZ4AX"
  payload = {
    channel: '#voicerepublic_tech',
    username: 'capistrano',
    text: message,
    icon_emoji: ':floppy_disk:'
  }
  json = JSON.unparse(payload)
  cmd = "curl -X POST --data-urlencode 'payload=#{json}' '#{url}' 2>&1"
  %x[ #{cmd} ]
end
