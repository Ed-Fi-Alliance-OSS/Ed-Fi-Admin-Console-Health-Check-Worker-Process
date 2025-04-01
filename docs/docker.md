# Docker Support for Ed-Fi-Admin-Console-Health-Check-Worker-Process

1. Having an Admin Api up and running is a requirement for `Health-Check-Worker-Process`.
   One option for setting it up quickly is by using docker as well, following these [instructions](https://github.com/Ed-Fi-Alliance-OSS/AdminAPI-2.x/blob/main/docs/docker.md). Take into account that Admin Api needs to be running with KeyCloak authentication
   enabled.

2. Copy and customize the `.env.template` file.

   ```shell
   cd docker
   cp .env.template .env
   code .env
   ```

3. Start containers.

   ```shell
   docker compose -f health-check-svc.yml --env-file .env up -d
   ```
