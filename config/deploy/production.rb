role :app, %w{deployer@178.62.225.200}
role :web, %w{deployer@178.62.225.200}
role :db,  %w{deployer@178.62.225.200}

set :rails_env, :production
set :stage, :production

server '178.62.225.200', user: 'deployer', roles: %w{web app db}, primary: true

set :ssh_options, {
  keys: %w(/Users/Jeiwan/.ssh/id_rsa),
  forward_agent: true,
  auth_methods: %w(publickey password),
  port: 1911
}
