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
  before :starting, "deploy:composer"
  before :updating, "deploy:upload_tarball"
  before :updating, "deploy:groupify"
  before :rollback, "deploy:groupify"
  after :published, "sentry:notify_deployment"
end

# Docker task
namespace :docker do
  set :branch, `git symbolic-ref HEAD 2> /dev/null`.strip.gsub(/^refs\/heads\//, '')

  task :deploy do
    invoke "deploy"
    invoke "docker:restart"
  end
  task :restart do
    invoke "docker:remove"
    on roles(:web) do
      execute %{
        cd #{fetch(:release_path)}
        DOMAIN="#{fetch(:docker_domain)}" docker-compose up -d
      }
    end
  end

  task :remove do
    on roles(:web) do
      execute %{
        cd #{fetch(:release_path)}
        CONTAINERS=$(docker ps -a | grep #{fetch(:docker_domain)} | awk '{print $1}')
        [ ! -z "$CONTAINERS" ] && docker ps -a | grep #{fetch(:docker_domain)} | awk '{print $1}' | xargs docker stop || echo "No containers stopped"
        [ ! -z "$CONTAINERS" ] && docker ps -a | grep #{fetch(:docker_domain)} | awk '{print $1}' | xargs docker rm || echo "No containers removed"
      }
    end
  end
end
