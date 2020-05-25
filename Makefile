SHELL := /bin/bash

.PHONY: docs backup

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile

all: # Run everything except build
	$(MAKE) fmt
	$(MAKE) lint
	$(MAKE) docs

fmt: # Format drone fmt
	@echo
	drone exec --pipeline $@

lint: # Run drone lint
	@echo
	drone exec --pipeline $@

docs: # Build docs
	@echo
	drone exec --pipeline $@

edit:
	docker-compose -f docker-compose.docs.yml pull docs
	docker-compose -f docker-compose.docs.yml run --rm docs

logs: # Logs for docker-compose
	docker-compose logs -f

up: # Run home container with docker-compose
	$(RENEW) docker-compose up -d

down: # Shut down home container
	docker-compose down

restart: # Restart home container
	$(RENEW) docker-compose restart

recreate: # Recreate home container
	-$(MAKE) down
	$(MAKE) up

backup: # Backup wordpress content
	docker-compose stop
	docker cp $(shell docker-compose ps -q wordpress):/bitnami/wordpress backup/
	docker cp $(shell docker-compose ps -q mariadb):/bitnami/mariadb backup/
	kitt up
	cd backup && git add . && git commit -m "backup: $(date)" && git push	

restore: # Restore wordpress content
	docker-compose stop wordpress-restore mariadb-restore
	docker cp backup/mariadb $(shell docker-compose ps -q mariadb-restore):/bitnami/
	docker cp backup/wordpress $(shell docker-compose ps -q wordpress-restore):/bitnami/
	kitt up
	docker-compose exec -u root wordpress-restore chown -R 1001:0 /bitnami/wordpress
