# FastCruise

[FastCruise](https://fastcruise.app) is the premium iOS client for Teslamate that puts you in complete control of your Tesla data. No monthly subscription fees, no data mining, no privacy concerns - just powerful Tesla analytics and insights with a simple one-time purchase.



## TeslaMate Setup for FastCruise

This is a Teslamate setup for FastCruise. It is a simple setup that can be used to test the TeslaMate API and the FastCruise integration. 

This repository provides two Docker Compose stacks for running and testing TeslaMate and its supporting services. Each stack is self-contained and located under the `compose/` directory:

- `fastcruise-teslamate`
- `fastcruise-teslamate-nginx`

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Stack Details](#stack-details)
  - [fastcruise-teslamate](#fastcruise-teslamate)
  - [fastcruise-teslamate-nginx](#fastcruise-teslamate-nginx)
- [Backup Procedures](#backup-procedures)
- [Environment Variables](#environment-variables)
- [Usage](#usage)
- [Notes](#notes)

---

## Overview

Each stack provides a full TeslaMate environment, including:

- TeslaMate (main application)
- TeslaMate API
- PostgreSQL database
- Grafana (for dashboards)
- Mosquitto (MQTT broker)
- (Optional) Nginx reverse proxy with basic authentication

The `fastcruise-teslamate-nginx` stack adds an Nginx reverse proxy in front of the API, with HTTP basic authentication.

---

## Directory Structure

```
compose/
  fastcruise-teslamate/
    compose.yaml
    backup.sh
    backups/
      info.txt
  fastcruise-teslamate-nginx/
    compose.yaml
    Dockerfile
    nginx.conf
    entrypoint.sh
    backup.sh
    backups/
      info.txt
```

---

## Stack Details

### fastcruise-teslamate

A standard TeslaMate stack with the following services:

- **teslamateapi**: Provides a REST API for TeslaMate data.
- **teslamate**: The main TeslaMate application.
- **database**: PostgreSQL 17, stores all TeslaMate data.
- **grafana**: For dashboards and visualization.
- **mosquitto**: MQTT broker for real-time data.

#### Key Features

- All services are connected via a custom Docker network (`teslamate-net`).
- Data is persisted using Docker volumes.
- Environment variables are loaded from `.env.*` files.
- Includes a `backup.sh` script for database backups.

### fastcruise-teslamate-nginx

Extends the standard stack with an Nginx reverse proxy:

- **nginx**: Sits in front of `teslamateapi`, providing HTTP basic authentication and HTTPS encryption.
  - Built from a custom `Dockerfile`.
  - Uses `nginx.conf` for configuration.
  - `entrypoint.sh` sets up the `.htpasswd` file for authentication using environment variables.
  - **Self-signed TLS certificate is generated automatically at container startup** (valid for 10 years) if not already present, enabling HTTPS on port 8443.
  - Only HTTPS (port 8443) is exposed; HTTP is not accessible from outside the container. Any HTTP requests inside the container are redirected to HTTPS.

Other services are the same as in `fastcruise-teslamate`.

#### Key Features

- Nginx listens on port 8443 for HTTPS and proxies requests to `teslamateapi:8080`.
- HTTP basic authentication is enforced for all API requests.
- Nginx credentials are set via `NGINX_AUTH_USER` and `NGINX_AUTH_PASSWORD` environment variables.
- Self-signed TLS certificate is generated at startup by `entrypoint.sh` if missing.
- Only HTTPS is exposed to the host (port 8443).

---

## Backup Procedures

Both stacks include a `backup.sh` script for backing up the PostgreSQL database.

- **Location**: `compose/fastcruise-teslamate/backup.sh` and `compose/fastcruise-teslamate-nginx/backup.sh`
- **Usage**: Run the script from within the respective stack directory.
- **Output**: Backups are saved in the `backups/` subdirectory, with a timestamped filename.
- **How it works**: The script uses `docker compose exec` to run `pg_dump` inside the database container.

Example:
```sh
./backup.sh
```

---

## Environment Variables

Each service loads its configuration from an environment file:

- `.env.teslamateapi`
- `.env.teslamate`
- `.env.postgres`
- `.env.grafana`
- `.env.nginx` (for the Nginx stack)

**Note:** Change the values in the `.env.*` files to your own.

For the Nginx stack, you must set:
- `NGINX_AUTH_USER`
- `NGINX_AUTH_PASSWORD`

---

## Usage

### 1. Prepare Environment Files

Create the required `.env.*` files in each stack directory.

### 2. Start the Stack

Navigate to the desired stack directory and run:

```sh
docker compose up -d
```

### 3. Access Services

- **TeslaMate UI**: http://localhost:4000
- **Grafana**: http://localhost:3000
- **TeslaMate API**: 
  - Standard stack: Exposed internally, not mapped to host by default.
  - Nginx stack: https://localhost:8443 (with HTTP basic auth and self-signed certificate)

### 4. Run Backups

```sh
./backup.sh
```
Backups will be stored in the `backups/` directory.

---

## Notes

- The Nginx stack is useful for scenarios where you want to expose the API securely with authentication.
- Both stacks use Docker named volumes for persistent data.
- The `backups/` directory contains an `info.txt` file as a placeholder and documentation.
- The Nginx container is built from the local Dockerfile and requires a rebuild if you change `nginx.conf` or `entrypoint.sh`.

---

## Troubleshooting

- Ensure all required environment files are present before starting the stack.
- If you encounter permission issues with backups, check directory permissions and Docker user mappings.
- For Nginx authentication issues, verify that `NGINX_AUTH_USER` and `NGINX_AUTH_PASSWORD` are set and valid.

---

## License

This project is for testing and development purposes. See upstream TeslaMate and related projects for their respective licenses. 