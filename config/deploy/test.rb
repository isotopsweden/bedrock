set :stage, :test

# Sentry release configuration
set :sentry_project, 'test'

# Deploy to server
server 'example.com', user: 'deploy', roles: %w{web}

# Merge default env variables.
fetch(:default_env).merge!(wp_env: :test)
