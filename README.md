# Traefik v2 HTTPS (SSL) on localhost

This repo is a minimal template to use Traefik v2 on localhost with HTTPS support.

## Installation

To get started, just clone this repo:

```sh
git clone https://github.com/todaypp/traefik-v2-https-ssl-localhost.git
```

The project is configured with Makefile thus can be handled with make commands.
To list the available commands:

```sh
make help
```

Also you can check the python (poetry) environment with:

```sh
make info
```


Next, go to the root of the repo (`cd traefik-v2-https-ssl-localhost`) and generate certificates using [mkcert](https://github.com/FiloSottile/mkcert) :

```sh
# If it's the firt install of mkcert, run
mkcert -install

# Generate certificates
mkcert \
  -cert-file ./certificates/localhost/cert.pem \
  -key-file ./certificates/localhost/key.pem \
  "localhost" \
  "127.0.0.1" \
  "docker.localhost" \
  "*.docker.localhost" \
  "api.localhost" \
  "app.localhost"

# Or with make command
make init
```

Create networks that will be used by Traefik:

```sh
docker network create reverse-proxy
```

Now, start containers with:

```sh
# Start docker compose
docker compose -f docker-compose.base.yml -f docker-compose.localhost.yml up -d --build

# Or with make command
make docker.local.up

# And check ps with
make docker.local.ps

# And check logs with
make docker.local.logs
```

And stop containers with:

```sh
# Stop docker compose
docker compose -f docker-compose.base.yml -f docker-compose.localhost.yml down

# Or with make command
make docker.local.down
```

You can now go to your browser at [whoami.docker.localhost](https://whoami.docker.localhost), enjoy :rocket: !

*Note: you can access to Træfik dashboard at: [traefik.docker.localhost](https://traefik.docker.localhost)*

Don't forget that you can also map TCP and UDP through Træfik.

## Code of Conduct

This project adheres to the [Contributor Covenant](https://www.contributor-covenant.org/). By participating in this project you agree to abide by its terms.

# License

MIT
