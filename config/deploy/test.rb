set :stage, :test

# Sentry release configuration
set :sentry_project, 'test'

# Deploy to server
server 'apps.frozzare.com', user: 'root', roles: %w{web}

# Merge default env variables.
fetch(:default_env).merge!(wp_env: :test)
