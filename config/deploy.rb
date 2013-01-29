require "bundler/capistrano"

set :application, "Arcanus"
set :user, "arcanus"
set :scm, :git
set :repository, "git@github.com:lenon/arcanus.git"
set :deploy_to, "/home/arcanus/app"
set :deploy_via, :copy
set :copy_exclude, [".git/", "config/", "spec/", "Capfile", ".rspec"]
set :keep_releases, 1
set :use_sudo, false
set :normalize_asset_timestamps, false
set :shared_children, %w(config log tmp/pids tmp/sockets)
set :bundle_without, [:development, :test, :deployment]
set :git_shallow_clone, 1

set :server_ip, "192.81.208.132"

role :web, server_ip
role :app, server_ip
role :db,  server_ip, primary: true

namespace :unicorn do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "/home/arcanus/app/current/scripts/unicorn/start"
  end
end

after "deploy:restart", "deploy:cleanup"
after "deploy:restart", "unicorn:restart"