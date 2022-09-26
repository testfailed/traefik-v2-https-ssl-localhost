.ONESHELL:
ENV_PREFIX=$(shell python -c "\
	if __import__('pathlib').Path('.venv/bin/pip').exists(): \
		print('.venv/bin/')\
")
DOCKER_COMPOSE_FILENAME="docker-compose"
DOCKER_COMPOSE_BASE="${DOCKER_COMPOSE_FILENAME}.base.yml"
DOCKER_COMPOSE_LOCALHOST="${DOCKER_COMPOSE_FILENAME}.localhost.yml"
CERT_PATH="./certificates"
CERT_LOCALHOST_PATH="${CERT_PATH}/localhost"

#
# General Commands
#

.PHONY: help
help:                   ## Show the help
	@echo
	@echo "Usage: make <target>"
	@echo
	@echo "[Targets]"
	@fgrep "##" Makefile | fgrep -v fgrep
	@echo

.PHONY: info
info:                   ## Show the current environment
	@echo "Current poetry environment:"
	@poetry env info
	@echo
	@echo "Running using $(ENV_PREFIX)"
	@$(ENV_PREFIX)python -V
	@echo
	@$(ENV_PREFIX)python -m site

#
# Project Commands
#

.PHONY: ci.all
ci.all:                 ## Run pre-commit-hooks for the whole files
	@pre-commit run --all-files --hook-stage manual

.PHONY: clean
clean:                  ## Clean unused files
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
init:                   ## Initialize git hooks and local certificates
	@pre-commit install --install-hooks
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
docker.local.build:     ## (local) Build docker compose images
	@docker compose -f "${DOCKER_COMPOSE_BASE}" -f "${DOCKER_COMPOSE_LOCALHOST}" \
		build

.PHONY: docker.local.logs
docker.local.logs:      ## (local) Watch all docker compose logs
	@docker compose -f "${DOCKER_COMPOSE_BASE}" -f "${DOCKER_COMPOSE_LOCALHOST}" \
		logs -f --tail all

.PHONY: docker.local.up
docker.local.up:        ## (local) Build and start docker compose containers
	@docker compose -f "${DOCKER_COMPOSE_BASE}" -f "${DOCKER_COMPOSE_LOCALHOST}" \
		up -d --build

.PHONY: docker.local.down
docker.local.down:      ## (local) Stop docker compos containers
	@docker compose -f "${DOCKER_COMPOSE_BASE}" -f "${DOCKER_COMPOSE_LOCALHOST}" \
		down

.PHONY: docker.local.ps
docker.local.ps:        ## (local) List docker compose containers
	@docker compose -f "${DOCKER_COMPOSE_BASE}" -f "${DOCKER_COMPOSE_LOCALHOST}" \
		ps
