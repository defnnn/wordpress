SHELL := /bin/bash

.PHONY: backup restore

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile

mirror: # Mirror wordpress site
	cd backup && sudo wget --recursive --no-clobber --page-requisites --html-extension --convert-links --restrict-file-names=windows https://press.defn.sh
	cd backup/press.defn.sh && sudo rm -rf xmlrpc* wp-login.php* wp-json && sudo git add . && (sudo git commit -m "mirror: $(shell date)" && sudo git push) || true

backup: # Backup wordpress content
	docker-compose stop
	sudo docker cp $(shell docker-compose ps -q wordpress):/bitnami/wordpress backup/
	sudo docker cp $(shell docker-compose ps -q mariadb):/bitnami/mariadb backup/
	kitt up
	cd backup && sudo git add . && sudo git commit -m "backup: $(shell date)" && sudo git push

restore: # Restore wordpress content
	cd restore && $(MAKE) restore

restore-main:
	docker-compose stop
	sudo docker cp backup/mariadb $(shell docker-compose ps -q mariadb):/bitnami/
	sudo docker cp backup/wordpress $(shell docker-compose ps -q wordpress):/bitnami/
	kitt up

imagemagick:
	echo extension=imagick.so | docker-compose run -T wordpress tee -a /opt/bitnami/php/etc/php.ini
	kitt restart wordpress
