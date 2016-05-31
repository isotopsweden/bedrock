# Basic settings for deploying.
set :application, 'my_app_name'
set :repo_url, 'git@example.com:me/my_repo.git'

# Hardcodes branch to always be master
# This could be overridden in a stage config file
set :branch, :master

# Use :debug for more verbose output when troubleshooting
set :log_level, :info

# Path to deploy directory.
set :deploy_to, ''

# Linked files and directories.
set :linked_files, fetch(:linked_files, []).push('.env')
set :linked_dirs, fetch(:linked_dirs, []).push('web/app/uploads')

# Sentry release configuration.
# https://gist.github.com/cannikin/2fc8134491943c04814b
set :sentry_org, ''
set :sentry_api_key, ''

# All deploy actions.
namespace :deploy do
  after :published, 'sentry:notify_deployment'
end
