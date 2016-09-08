# Basic settings for deploying.
set :application, "bedrock"
set :repo_url, "git@github.com:isotopsweden/bedrock.git"
set :docker_domain, -> { "#{fetch(:branch).split("/").last}.example.com" }
set :user, "deploy"

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

# All deploy actions.
namespace :deploy do
  SSHKit.config.command_map[:composer] = "php #{shared_path.join("composer.phar")}"

  after :updating, "deploy:groupify_web"
  before :updating, "deploy:upload_tarball"
  before :rollback, "deploy:groupify_web"
  before :publishing, "deploy:groupify_shared"

  after :starting, "composer:install_executable"
  after :published, "sentry:notify_deployment"
end

# Docker task
namespace :docker do
  # Find branch to deploy with.
  set :branch, ENV['CI_BUILD_REF_NAME'] || `git symbolic-ref HEAD 2> /dev/null`.strip.gsub(/^refs\/heads\//, '')

  # Deploy to custom path for each branch.
  set :deploy_to, -> { "/mnt/persist/#{fetch(:application)}/#{fetch(:branch)}" }

  # Find email to use.
  set :docker_email, `git log --pretty=email -n 1|grep -o '[[:alnum:]+\.\_\-]*@[[:alnum:]+\.\_\-]*'`.strip.gsub(';','')

  # Use root
  set :user, 'root'

  # No linked files.
  set :linked_files, []

  # No linked directories.
  set :linked_dirs, []

  task :deploy do
    invoke "deploy"
    invoke "docker:restart"
  end

  task :list do
    on roles(:web) do
      execute %{
        docker ps -a | grep #{fetch(:docker_domain)}
      }
    end
  end

  task :restart do
    on roles(:web) do
      if fetch(:docker_domain)[0] != "."
        execute %{
          cd #{fetch(:release_path)}
          export DOMAIN="#{fetch(:docker_domain)}"
          export EMAIL="#{fetch(:docker_email)}"
          CONTAINERS=$(docker ps -a | grep #{fetch(:docker_domain)} | awk '{print $1}')
          [ -z "$CONTAINERS" ] && DOMAIN="#{fetch(:docker_domain)}" docker-compose up -d || echo "Docker: Container exists"
          [ ! -z "$CONTAINERS" ] && (docker stop $CONTAINERS || echo "Docker: No container stopped") && (docker rm $CONTAINERS || echo "Docker: No container removed") && docker-compose up -d --no-recreate --no-deps web || echo "Docker: Failed when trying to restart container"
          docker ps -a | grep #{fetch(:docker_domain)} | awk '{print $1}'
        }
      else
        puts "Bad docker domain #{fetch(:docker_domain)}"
      end
    end
  end

  task :remove do
    on roles(:web) do
      execute %{
        CONTAINERS=$(docker ps -a | grep #{fetch(:docker_domain)} | awk '{print $1}')
        [ ! -z "$CONTAINERS" ] && docker ps -a | grep #{fetch(:docker_domain)} | awk '{print $1}' | xargs docker stop || echo "Docker: No containers stopped"
        [ ! -z "$CONTAINERS" ] && docker ps -a | grep #{fetch(:docker_domain)} | awk '{print $1}' | xargs docker rm || echo "Docker: No containers removed"
      }
    end
  end
end
