.ONESHELL:
ENV_PREFIX=$(shell python -c "if __import__('pathlib').Path('.venv/bin/pip').exists(): print('.venv/bin/')")
DOCKER_COMPOSE_BASE="docker-compose.base.yml"
DOCKER_COMPOSE_LOCALHOST="docker-compose.localhost.yml"
CERT_PATH="./certificates"
CERT_LOCALHOST_PATH="${CERT_PATH}/localhost"

#
# General Commands
#

.PHONY: help
help:                   ## Show the help.
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "[Targets]"
	@fgrep "##" Makefile | fgrep -v fgrep
	@echo ""

.PHONY: info
info:                   ## Show the current environment.
	@echo "Current poetry environment:"
	@poetry env info
	@echo ""
	@echo "Running using $(ENV_PREFIX)"
	@$(ENV_PREFIX)python -V
	@echo ""
	@$(ENV_PREFIX)python -m site

#
# Project Commands
#

.PHONY: build
build:                  ## Build the project.
	@poetry build -vvv

.PHONY: clean
clean:                  ## Clean unused files.
	@find ./ -name '*.pyc' -exec rm -f {} \;
	@find ./ -name '__pycache__' -exec rm -rf {} \;
	@find ./ -name 'Thumbs.db' -exec rm -f {} \;
	@find ./ -name '*~' -exec rm -f {} \;
	@rm -rf .cache
	@rm -rf .pytest_cache
	@rm -rf .mypy_cache
	@rm -rf build
	@rm -rf dist
	@rm -rf *.egg-info
	@rm -rf htmlcov
	@rm -rf .tox/
	@rm -rf docs/_build

.PHONY: init
init:                   ## Initialize local certificates with mkcert
	@mkcert -install
	@mkdir -p "${CERT_LOCALHOST_PATH}"
	@mkcert \
	-cert-file "${CERT_LOCALHOST_PATH}/cert.pem" \
	-key-file "${CERT_LOCALHOST_PATH}/key.pem" \
	"localhost" \
	"127.0.0.1" \
	"docker.localhost" \
	"*.docker.localhost" \
	"api.localhost" \
	"app.localhost"

#
# Docker Commands
#

.PHONY: docker.local.build
docker.local.build:     ## Builder docker images
	@docker compose -f "${DOCKER_COMPOSE_BASE}" -f "${DOCKER_COMPOSE_LOCALHOST}" build

.PHONY: docker.local.logs
docker.local.logs:      ## Bring down docker dev environment
	@docker compose -f "${DOCKER_COMPOSE_BASE}" -f "${DOCKER_COMPOSE_LOCALHOST}" logs -f --tail all

.PHONY: docker.local.up
docker.local.up:        ## Run docker development images
	@docker compose -f "${DOCKER_COMPOSE_BASE}" -f "${DOCKER_COMPOSE_LOCALHOST}" up -d --build

.PHONY: docker.local.down
docker.local.down:      ## Bring down docker dev environment
	@docker compose -f "${DOCKER_COMPOSE_BASE}" -f "${DOCKER_COMPOSE_LOCALHOST}" down

.PHONY: docker.local.ps
docker.local.ps:        ## Bring down docker dev environment
	@docker compose -f "${DOCKER_COMPOSE_BASE}" -f "${DOCKER_COMPOSE_LOCALHOST}" ps
