# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'stackunderflow'
set :repo_url, 'git@github.com:Jeiwan/StackUnderflow.git'
set :deploy_to, '/home/deployer/stackunderflow'
set :deploy_user, 'deployer'
set :linked_files, %w{config/database.yml config/private_pub.yml .env}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :bundle_flags, "--without development test --deployment"

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart
end
