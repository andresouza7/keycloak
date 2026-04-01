# Keycloak Custom Build for Render Deployment

This repository contains a `Dockerfile` for building and deploying a customized [Keycloak](https://www.keycloak.org/) instance, specifically optimized for deployment on platform-as-a-service providers like [Render](https://render.com/).

## Features

- **Base Image:** Uses the official `quay.io/keycloak/keycloak:latest` Docker image.
- **Database:** Configured to use **PostgreSQL** (`KC_DB=postgres`).
- **Monitoring & Health:** Enables Keycloak Health (`KC_HEALTH_ENABLED=true`) and Metrics (`KC_METRICS_ENABLED=true`) endpoints.
- **Proxy Configuration:** Optimized for environments where SSL is terminated at the Load Balancer/Reverse Proxy level (`KC_PROXY=edge`, `KC_HOSTNAME_STRICT=false`, `KC_HTTP_ENABLED=true`).
- **Port mapping:** Exposes and runs on the default port `8080`.

## How it works

The Dockerfile uses a multi-stage approach:

### 1. Builder Stage
In the first stage, it configures fundamental environment variables (like the database type, metrics, and health endpoints) and runs the `/opt/keycloak/bin/kc.sh build` command. This creates an optimized build of Keycloak with the requested features baked in, reducing startup time later.

### 2. Runtime Stage
The second stage copies the optimized build from the builder stage into a fresh image. It sets the runtime environment variables required for running behind a reverse proxy (like Render's routing layer), ensuring Keycloak correctly handles forwarded headers and scheme. Finally, it starts Keycloak using the `--optimized` flag.

## Deployment Details (Render)

When deploying this image to Render:
1. Ensure the internal routing/health-check port is set to `8080`.
2. As Keycloak requires a database, you must provide a valid PostgreSQL connection via environment variables (e.g., `KC_DB_URL`, `KC_DB_USERNAME`, `KC_DB_PASSWORD`) in your Render service settings.
3. You will also need to supply the initial admin credentials (`KEYCLOAK_ADMIN` and `KEYCLOAK_ADMIN_PASSWORD`).

## Local Testing

To build the image locally:

```bash
docker build -t custom-keycloak .
```

To run it locally (you will need a running Postgres database or you can run it without one by skipping the DB config if possible, but it expects Postgres by default):

```bash
docker run -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB_URL=jdbc:postgresql://<YOUR_POSTGRES_HOST>/<DB_NAME> \
  -e KC_DB_USERNAME=<DB_USER> \
  -e KC_DB_PASSWORD=<DB_PASS> \
  custom-keycloak
```
