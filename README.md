# Custom [Bedrock](https://roots.io/bedrock/) setup

## Capistrano

Not a working deployment setup with the existing files, but can be added in the projects using this setup.

## Docker

### Docker testing

```
docker network create test
docker run -d -p 80:80 --net test -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
DOMAIN=docker-web-test.dev docker-compose up
```
