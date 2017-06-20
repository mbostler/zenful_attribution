# config valid only for current version of Capistrano
lock "3.8.2"

set :application, "zenful_attribution"
set :username, "satori"
set :host, "10.120.44.206"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :repo_url, "https://github.com/mbostler/zenful_attribution.git"

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :deploy_to, "/home/#{fetch(:username)}/var/www/deploy/#{fetch(:application)}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml", 
                      "config/secrets.yml", 
                      "config/unicorn.conf.rb"


# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5
after "deploy:finishing", :restart_services do
# after "deploy:restart", :restart_services do
  invoke "restart_unicorn"
end

task :restart_unicorn do
  on roles(:app) do
    # execute "sudo service zenful_attribution_unicorn restart"
  end  
end