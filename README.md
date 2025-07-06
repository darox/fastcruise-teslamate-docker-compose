# FastCruise

[FastCruise](https://fastcruise.app) is the premium iOS client for Teslamate that puts you in complete control of your Tesla data. No monthly subscription fees, no data mining, no privacy concerns - just powerful Tesla analytics and insights with a simple one-time purchase.



## TeslaMate Setup for FastCruise

This is a Teslamate setup for FastCruise. It is a simple setup that can be used to test the TeslaMate API and the FastCruise integration. 

This repository provides **three** Docker Compose stacks for running and testing TeslaMate and its supporting services. Each stack is self-contained and located under the `compose/` directory:

- `fastcruise-teslamate`
- `fastcruise-teslamate-nginx`
- `fastcruise-teslamate-nginx-ngrok` (**recommended, easiest for remote access**)

> **Recommended:** Use the `fastcruise-teslamate-nginx-ngrok` stack by default. It provides secure, authenticated, and public access to the TeslaMate API via ngrok, making remote testing and integration with FastCruise seamless. Obtain your ngrok authtoken from [ngrok.com](https://dashboard.ngrok.com/get-started/your-authtoken) and add it to the `.env.ngrok` file.

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Stack Details](#stack-details)
  - [fastcruise-teslamate](#fastcruise-teslamate)
  - [fastcruise-teslamate-nginx](#fastcruise-teslamate-nginx)
  - [fastcruise-teslamate-nginx-ngrok](#fastcruise-teslamate-nginx-ngrok)
- [Backup Procedures](#backup-procedures)
- [Environment Variables](#environment-variables)
- [Usage](#usage)
- [Notes](#notes)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

> **Important:**
> Before running any stack, you must review and change the values in **all** `.env.*` files in each stack directory. Do **not** use the default/example values in production or with real accounts. Each stack may have its own set of `.env.*` files—make sure to update every one for security and proper operation.

## Overview

Each stack provides a full TeslaMate environment, including:

- TeslaMate (main application)
- TeslaMate API
- PostgreSQL database
- Grafana (for dashboards)
- Mosquitto (MQTT broker)
- (Optional) Nginx reverse proxy with basic authentication
- (Optional) **ngrok tunnel for public, secure API access**

The `fastcruise-teslamate-nginx` stack adds an Nginx reverse proxy in front of the API, with HTTP basic authentication. The `fastcruise-teslamate-nginx-ngrok` stack further adds ngrok to expose the API securely to the internet.

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
  fastcruise-teslamate-nginx-ngrok/
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

### fastcruise-teslamate-nginx-ngrok (**Recommended**)

Extends the Nginx stack by adding **ngrok** for secure, public API access:

- **ngrok**: Exposes the Nginx-protected API to the internet via a secure tunnel. You get a public HTTPS URL for remote access and integration/testing.
  - Uses settings from `.env.ngrok` (see below).
  - The ngrok web interface is available at http://localhost:4040 for inspecting tunnel status and traffic.
- **nginx**: As above, provides HTTP basic authentication in front of the API.
- All other services are the same as in the other stacks.

#### Key Features

- **Public, secure API access**: Instantly get a public HTTPS URL for the TeslaMate API, protected by HTTP basic auth.
- **No need to configure firewalls or port forwarding**: ngrok handles secure tunneling.
- **Recommended for most users and for FastCruise integration.**
- Nginx credentials are set via `NGINX_AUTH_USER` and `NGINX_AUTH_PASSWORD`.
- ngrok configuration is set via `.env.ngrok` (see below for required variables).
- The ngrok web interface is available at http://localhost:4040.

---

## Backup Procedures

All stacks include a `backup.sh` script for backing up the PostgreSQL database.

- **Location**: Each stack's directory (e.g., `compose/fastcruise-teslamate-nginx-ngrok/backup.sh`)
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
- `.env.nginx` (for the Nginx and ngrok stacks)
- `.env.ngrok` (**for the ngrok stack**)

**Note:** Change the values in the `.env.*` files to your own.

For the Nginx and ngrok stacks, you must set:
- `NGINX_AUTH_USER`
- `NGINX_AUTH_PASSWORD`

For the ngrok stack, you must also set (in `.env.ngrok`):
- `NGROK_AUTHTOKEN` (your ngrok account token, required for stable tunnels)
- Optionally, other ngrok settings (see [ngrok docs](https://ngrok.com/docs) for advanced usage)

> **Important:**
> You must update the environment variables in **all** `.env.*` files in every stack directory before starting any stack. Default/example values are not secure and should not be used with real accounts or in production environments.

---

## Usage

### 1. Prepare Environment Files

Create the required `.env.*` files in each stack directory. For the ngrok stack, ensure you have a valid `.env.ngrok` with your ngrok authtoken.

### 2. Start the Stack

Navigate to the desired stack directory and run:

```sh
cd compose/fastcruise-teslamate-nginx-ngrok
# or your chosen stack directory

docker compose up -d
```

### 3. Access Services

- **TeslaMate UI**: http://localhost:4000
- **Grafana**: http://localhost:3000
- **TeslaMate API**: 
  - Standard stack: Exposed internally, not mapped to host by default.
  - Nginx stack: https://localhost:8443 (with HTTP basic auth and self-signed certificate)
  - **ngrok stack (recommended):** Public HTTPS URL (shown in ngrok logs or at http://localhost:4040) — use this for FastCruise and remote access.

### 4. Run Backups

```sh
./backup.sh
```
Backups will be stored in the `backups/` directory.

---

## Notes

- **The ngrok stack is recommended for most users.** It provides secure, authenticated, and public access to the TeslaMate API with minimal setup.
- Both Nginx and ngrok stacks use Docker named volumes for persistent data.
- The `backups/` directory contains an `info.txt` file as a placeholder and documentation.
- The Nginx container is built from the local Dockerfile and requires a rebuild if you change `nginx.conf` or `entrypoint.sh`.
- The ngrok web interface is available at http://localhost:4040 for tunnel status and inspection.
- For ngrok, you must provide your own [ngrok authtoken](https://dashboard.ngrok.com/get-started/your-authtoken) in `.env.ngrok`.

---

## Troubleshooting

- Ensure all required environment files are present before starting the stack.
- If you encounter permission issues with backups, check directory permissions and Docker user mappings.
- For Nginx authentication issues, verify that `NGINX_AUTH_USER` and `NGINX_AUTH_PASSWORD` are set and valid.
- For ngrok issues, ensure your `NGROK_AUTHTOKEN` is valid and present in `.env.ngrok`. Check ngrok logs and the web interface at http://localhost:4040 for details.

---

## License

This project is for testing and development purposes. See upstream TeslaMate and related projects for their respective licenses. 