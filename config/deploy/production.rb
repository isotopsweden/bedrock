set :stage, :production

# Sentry release configuration
set :sentry_project, 'production'

# Deploy to server
server 'example.com', user: 'deploy', roles: %w{web}

# Merge default env variables.
fetch(:default_env).merge!(wp_env: :production)
