# Custom [Bedrock](https://roots.io/bedrock/) setup

## Docker

### Docker testing

Run this once (without cert):

```
docker network create test
docker run -d -p 80:80 --net test -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
```

Run this once (with cert using Let's Encrypt):

```
docker run -d -p 80:80 -p 443:443 \
  --net test \
  --name nginx-proxy \
  -v /path/to/certs:/etc/nginx/certs:ro \
  -v /etc/nginx/vhost.d \
  -v /usr/share/nginx/html \
  -v /var/run/docker.sock:/tmp/docker.sock:ro \
  jwilder/nginx-proxy

docker run -d \
  --net test \
  -v /path/to/certs:/etc/nginx/certs:rw \
  --volumes-from nginx-proxy \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  jrcs/letsencrypt-nginx-proxy-companion
```

Run this for every instance:

```
DOMAIN="docker-web-test.dev" docker-compose up
```

Remove a single instance of containers:

```
DOMAIN="docker-web-test.dev" docker rm $(docker stop $(docker ps -a -q --filter name="$DOMAIN" --format="{{.ID}}"))
```
