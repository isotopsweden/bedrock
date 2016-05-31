# Deploy WordPress with capistrano
#
# Command:
# - bundle exec cap staging deploy

# Basic settings for deploying, like name, repository url and deploy to path.
set :application, ''
set :repo_url, ''

# Path to deploy directory.
set :deploy_to, ''

# Sentry release configuration.
# https://gist.github.com/cannikin/2fc8134491943c04814b
set :sentry_org, ''
set :sentry_api_key, ''

# All deploy actions will live under "bundle exec cap staging deploy:".
namespace :deploy do
  after :published, 'sentry:notify_deployment'
end
