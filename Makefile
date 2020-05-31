up:
	docker-compose up jupyterhub 
down:
	docker-compose down jupyterhub
build:
	docker-compose build jupyterhub
cert:
	sudo ./init-letsencrypt.sh

