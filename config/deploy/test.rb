set :stage, :test

# Sentry release configuration
set :sentry_project, ''

# After hooks need a role
role :web, %w{deploy@}

# Deploy to server
server '', user: 'deploy', roles: %w{web}
