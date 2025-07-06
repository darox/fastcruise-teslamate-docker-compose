# FastCruise

[FastCruise](https://fastcruise.app) is the premium iOS client for Teslamate that puts you in complete control of your Tesla data. No monthly subscription fees, no data mining, no privacy concerns - just powerful Tesla analytics and insights with a simple one-time purchase.

## Prerequisites

- Docker
- Docker Compose
- Ngrok account (optional but required for remote access via Internet)

## Setup

This repository contains three docker compose stacks that can be used to test the Fastcruise iOS client.

**Important:** You must update the environment variables in **all** `.env.*` files in every stack directory before starting any stack. Default/example values are not secure and should not be used with real accounts or in production environments.


To start any environment, run the following command in any of the stack directories:
```bash
docker compose up -d
```

If you want to change the basic authentication credentials, you must run `docker compose build nginx` in the stack directory. Restart the stack to apply the changes.

On the first run, you will have to login to your Tesla account via http://localhost:4000. 

If you're using ngrok, you can obtain the ngrok URL from the ngrok dashboard or http://localhost:4040.

### 1. fastcruise-Teslamate-nginx-ngrok

This stack adds the following features on top of Teslamate:
- Teslamate API
- Ngrok tunnel to the Teslamate API to make it accessible from the internet
- Basic authentication to the Teslamate API

Obtain your ngrok authtoken from [ngrok.com](https://dashboard.ngrok.com/get-started/your-authtoken) and add it to the `.env.ngrok` file. 
**This is the recommended stack to use.**

### 2. fastcruise-Teslamate-nginx

This stack adds the following features on top of Teslamate:
- Teslamate API
- Basic authentication to the Teslamate API

### 3. fastcruise-Teslamate

This stack just provides the Teslamate API on top of Teslamate. 

## Appriciation

This project would have been not possible without the great work of the [Teslamate](https://github.com/teslamate-org/teslamate) and [Teslmate API](https://github.com/tobiasehlert/teslamateapi) teams.

## License

See the Teslamate and Teslamate API projects licenses for more information.