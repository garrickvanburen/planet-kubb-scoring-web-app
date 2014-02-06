require 'bundler/capistrano'

load 'deploy' if respond_to?(:namespace)

set :application, "pk-scoresheet"
set :user, "garrick"
set :use_sudo, false

set :scm, :git
set :repository,  "git@bitbucket.org:garrickvanburen/pk-scoresheet.git"
set :deploy_via, :copy
set :deploy_to, "/srv/www/kubbstats"

ssh_options[:port] = 22000

role :app, "69.164.207.227"
role :web, "69.164.207.227"

set :runner, user
set :admin_runner, user

namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C config.yml start --server 1 --port 3500"
  end

  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C config.yml stop --server 1  --port 3500"
  end

  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end

  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.start
  end
end

namespace :typerighter do
  task :log do
    run "cat #{deploy_to}/current/log/thin.log"
  end
end