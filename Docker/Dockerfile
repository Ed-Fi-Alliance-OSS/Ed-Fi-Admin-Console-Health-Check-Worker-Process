# Image based on .NET SDK to compile and publish the application

FROM mcr.microsoft.com/dotnet/sdk:8.0.401-alpine3.20@sha256:658c93223111638f9bb54746679e554b2cf0453d8fb7b9fed32c3c0726c210fe AS build

WORKDIR /source


# Copy source code and compile the application
COPY Application/EdFi.AdminConsole.HealthCheckService/. ./EdFi.AdminConsole.HealthCheckService/

WORKDIR /source/EdFi.AdminConsole.HealthCheckService



# Restore dependencies, Then build and publish release
RUN dotnet restore &&\
  dotnet publish -c Release -o /app


# .NET Runtime image to execute the application

FROM mcr.microsoft.com/dotnet/runtime:8.0.11 AS runtime

# Install Cron.
RUN apt-get update && apt-get install -y cron

# Add cron from file and adjust permissions
COPY crontab /etc/cron.d/container_cronjob

RUN chmod 0644 /etc/cron.d/container_cronjob

RUN crontab /etc/cron.d/container_cronjob


WORKDIR /app

# Add Published executable
COPY --from=build /app .

# Execute the app via chron
CMD ["cron", "-f"]
