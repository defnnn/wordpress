SHELL := /bin/bash

.PHONY: docs backup restore

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
	sudo docker cp $(shell docker-compose ps -q wordpress):/bitnami/wordpress backup/
	sudo docker cp $(shell docker-compose ps -q mariadb):/bitnami/mariadb backup/
	kitt up
	cd backup && sudo git add . && sudo git commit -m "backup: $(date)" && sudo git push

restore: # Restore wordpress content
	cd restore && $(MAKE) restore

restore-main:
	docker-compose stop
	sudo docker cp backup/mariadb $(shell docker-compose ps -q mariadb):/bitnami/
	sudo docker cp backup/wordpress $(shell docker-compose ps -q wordpress):/bitnami/
	kitt up
