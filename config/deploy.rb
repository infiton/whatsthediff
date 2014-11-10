# config valid only for Capistrano 3.1
lock '3.1.0'
# read http://capistranorb.com/documentation/getting-started/flow/ for flow control of cap stage deploy
set :application, 'whatsthediff'
set :repo_url, 'git@github.com:infiton/whatsthediff.git'
set :deploy_to, '/var/www/whatsthediff'
set :scm, :git
set :branch, "master"
set :user, "deploy"
set :group, "deployers"
set :ssh_options, { :forward_agent => true }
set :keep_releases, 5
set :format, :pretty
set :pty, true
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_files, %w{config/database.yml config/application.yml config/mongoid.yml}

set(:config_files, %w(
  database.yml
  application.yml
  mongoid.yml
))

#some custom tasks coming from https://github.com/TalkingQuickly/capistrano-3-rails-template/blob/master/
namespace :deploy do
  before :deploy, "deploy:check_revision"
  before :deploy, 'deploy:setup_config'
  after 'deploy:publishing', 'deploy:restart' 
end