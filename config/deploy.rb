# Basic settings for deploying.
set :application, "my_app_name"
set :repo_url, "git@example.com:me/my_repo.git"
set :docker_domain, -> { "#{fetch(:branch).split("/").last}.example.com" }

# Hardcodes branch to always be master
# This could be overridden in a stage config file
set :branch, :master

# Use :debug for more verbose output when troubleshooting
set :log_level, :info

# Path to deploy directory.
set :deploy_to, -> { "/tmp/#{fetch(:application)}/#{fetch(:branch)}" }

# Linked files and directories.
set :linked_files, fetch(:linked_files, []).push(".env")
set :linked_dirs, fetch(:linked_dirs, []).push("web/app/uploads")

# Sentry release configuration.
# https://gist.github.com/cannikin/2fc8134491943c04814b
set :sentry_org, ""
set :sentry_api_key, ""

# All deploy actions.
namespace :deploy do
  after :published, 'sentry:notify_deployment'
end

namespace :docker do
  set :branch, `git symbolic-ref HEAD 2> /dev/null`.strip.gsub(/^refs\/heads\//, '')

  task :deploy do
    set :deploy_to, -> { "/tmp/#{fetch(:application)}/#{fetch(:branch)}" }
    invoke "deploy"
    invoke "docker:restart"
  end

  task :restart do
    on roles(:all) do
      execute %{
        cd #{fetch(:release_path)}
        DOMAIN="#{fetch(:docker_domain)}" CONTAINERS=$(docker ps -a -q --filter name="$DOMAIN" --format="{{.ID}}")
        [ ! -z "$CONTAINERS" ] && DOMAIN="#{fetch(:docker_domain)}" docker rm $(docker stop $(docker ps -a -q --filter name="$DOMAIN" --format="{{.ID}}"))
        DOMAIN="#{fetch(:docker_domain)}" docker-compose up -d
      }
    end
  end
end
