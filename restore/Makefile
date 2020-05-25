SHELL := /bin/bash

restore:
	docker-compose down -v
	kitt up
	sleep 20
	docker-compose stop
	sudo perl -pe 's{mariadb:3306}{mariadb-restore:3306}' -i ../backup/wordpress/wp-config.php
	$(MAKE) restore-inner
	sudo perl -pe 's{mariadb-restore:3306}{mariadb:3306}' -i ../backup/wordpress/wp-config.php
	kitt up

restore-inner:
	sudo docker cp ../backup/mariadb $(shell docker-compose ps -q mariadb-restore):/bitnami/
	sudo docker cp ../backup/wordpress $(shell docker-compose ps -q wordpress-restore):/bitnami/
