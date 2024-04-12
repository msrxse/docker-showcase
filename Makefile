DATABASE_URL:=postgres://postgres:foobarbaz@localhost:5432/postgres

.PHONY: run-postgres
run-postgres:
	@echo Starting postgres container
	-docker run \
		-e POSTGRES_PASSWORD=foobarbaz \
		-v pgdata:/var/lib/postgresql/data \
		-p 5432:5432 \
		postgres:15.1-alpine

.PHONY: run-api-node
run-api-node:
	@echo Starting node api
	cd api-node && \
		DATABASE_URL=${DATABASE_URL} \
		npm run dev

.PHONY: run-client-react
run-client-react:
	@echo Starting react client
	cd client-react && \
		npm run dev
		
### DOCKER COMPOSE COMMANDS

.PHONY: compose-build
compose-build:
	docker compose build

.PHONY: compose-up
compose-up:
	docker compose up

.PHONY: compose-up-build
compose-up-build:
	docker compose up --build

.PHONY: compose-down
compose-down:
	docker compose down
	
### DOCKER CLI COMMANDS	

.PHONY: docker-build-all
docker-build-all:
	docker build -t client-react-vite -f client-react/Dockerfile.dev client-react/

	docker build -t client-react-nginx -f client-react/Dockerfile client-react/

	docker build -t api-node -f api-node/Dockerfile api-node/

DATABASE_URL:=postgres://postgres:foobarbaz@db:5432/postgres

.PHONY: docker-run-all
docker-run-all:
	echo "$$DOCKER_COMPOSE_NOTE"

	# Stop and remove all running containers to avoid name conflicts
	$(MAKE) docker-stop

	$(MAKE) docker-rm

	docker network create my-network

	docker run -d \
		--name db \
		--network my-network \
		-e POSTGRES_PASSWORD=foobarbaz \
		-v pgdata:/var/lib/postgresql/data \
		-p 5432:5432 \
		--restart unless-stopped \
		postgres:15.1-alpine

	docker run -d \
		--name api-node \
		--network my-network \
		-e DATABASE_URL=${DATABASE_URL} \
		-p 3000:3000 \
		--restart unless-stopped \
		--link=db \
		api-node

	docker run -d \
		--name client-react-vite \
		--network my-network \
		-v ${PWD}/client-react/vite.config.js:/usr/src/app/vite.config.dev.js \
		-p 5173:5173 \
		--restart unless-stopped \
		--link=api-node \
		client-react-vite

	docker run -d \
		--name client-react-nginx \
		--network my-network \
		-p 80:8080 \
		--restart unless-stopped \
		--link=api-node \
		client-react-nginx

.PHONY: docker-stop
docker-stop:
	-docker stop db
	-docker stop api-node
	-docker stop client-react-vite
	-docker stop client-react-nginx

.PHONY: docker-rm
docker-rm:
	-docker container rm db
	-docker container rm api-node
	-docker container rm client-react-vite
	-docker container rm client-react-nginx
	-docker network rm my-network