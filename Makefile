SHELL := /bin/bash

.PHONY: backup restore

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile

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
