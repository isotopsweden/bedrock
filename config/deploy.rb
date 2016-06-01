# Basic settings for deploying.
set :application, "bedrock"
set :repo_url, "git@github.com:isotopsweden/bedrock.git"
set :docker_domain, -> { "#{fetch(:branch).split("/").last}.example.com" }
set :user, "deploy"

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
set :sentry_org, ""
set :sentry_api_key, ""

# Composer with `--quiet` flag will not output anything so delete it from `prerequisites` list.
Rake::Task["deploy:updated"].prerequisites.delete("composer:install")

# All deploy actions.
namespace :deploy do
  SSHKit.config.command_map[:composer] = "php #{shared_path.join("composer.phar")}"
  after "deploy:starting", 'composer:install_executable'
  before :updating, "deploy:upload_tarball"
  before :updating, "deploy:groupify_web"
  before :rollback, "deploy:groupify_web"
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
