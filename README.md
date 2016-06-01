# Custom [Bedrock](https://roots.io/bedrock/) setup

## Capistrano

Not a working deployment setup with the existing files, but can be added in the projects using this setup.

## Docker

### Docker testing

Run this once:

```
docker network create test
docker run -d -p 80:80 --net test -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
```

Run this for every instance:

```
DOMAIN="docker-web-test.dev" docker-compose up
```

Remove a single instance of containers:

```
DOMAIN="docker-web-test.dev" docker rm $(docker stop $(docker ps -a -q --filter name="$DOMAIN" --format="{{.ID}}"))
```
