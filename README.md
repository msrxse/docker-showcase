# Docker showcase web application

![](./readme-assets/app-screenshot.png)

## Minimal 3 tier web application
- **React frontend:** Uses react query to load data from the two apis and display the result
- **Node JS API:** Do have `/` and `/ping` endpoints. `/` queries the Database for the current time, and `/ping` returns `pong`
- **Postgres Database:** An empty PostgreSQL database with no tables or data. Used to show how to set up connectivity. The API applications execute `SELECT NOW() as now;` to determine the current time to return.

![](./readme-assets/tech-stack.png)

## Running the Application

While the whole point of this app is that you probably won't want/need to run the application locally, we can do so as a starting point.

The `Makefile` contains the commands to start each application.

### Postgres

It's way more convenient to run postgres in a container, so we will do that.

`make run-postgres` will start postgres in a container and publish port 5432 from the container to your localhost.

### api-node

To run the node api you will need to run `npm install` to install the dependencies.

After installing the dependencies, `make run-api-node` will run the api in development mode with nodemon for restarting the app when you make source code changes.

### client-react

Like `api-node`, you will first need to install the dependencies with `npm install`

After installing the dependencies, `make run-client-react` will use vite to run the react app in development mode.

# Running Containers (with Docker)

There are two primary ways to run docker containers, with `docker run` and `docker compose up`. 

![](./readme-assets/docker-run-compose.jpeg)

Docker run takes a single container image and runs a container based on it, while docker compose takes a specification of 1 or more services and can build container images for them and/or run containers from those images.

Generally `docker run` is preferable for one off quick use cases while docker compose is preferable if you are developing a containerized application with more than one service.

## individual docker run commands

The portion of the Makefile labeled `### DOCKER CLI COMMANDS` shows the commands can would use to build and run all of these services. To build the images and then run them you can execute:

```bash
make docker-build-all
make docker-run-all
```

You will notice that each of the run commands has a bunch of options used to ensure the configuration works properly.

- Uses the default docker bridge network
- -d = detach mode
- Uses `--link` to enable easy host name for network connections
- Publishing ports (`-p` option) useful to connect to each service individually from host, but only necessary to connect to the frontend
- Named containers make it easier to reference (e.g. with link), but does require removing them to avoid naming conflict
- Restart policy allows docker to restart the container (for example if database weren't up yet causing one of the api servers to crash)
- -v option on client-react-vite because vite.config needs to be different on vite than on nginx


## docker compose

Using docker compose allows encoding all of the logic from the `docker build` and `docker run` commands into a single file. Docker compose also manages naming of the container images and containers, attaching to logs from all the containers at runtime, etc...

The `docker-compose.yml` file and the portion of the Makefile labeled `### DOCKER COMPOSE COMMANDS` shows how you can use docker compose to build and run the services. To build and run them you can execute

```bash
make compose-up-build
```

As you can see, this is much simpler than needing to execute all of the individual build/run commands and provides a clear way to specify the entire application stack in a single file!
