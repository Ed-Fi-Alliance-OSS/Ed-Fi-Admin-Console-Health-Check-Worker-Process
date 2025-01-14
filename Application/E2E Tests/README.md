# E2E tests

This folder contains some scripts to start the necessary Docker containers in order to be able to execute the e2e tests, along with the e2e tests itself.

## How it works

To execute the e2e tests we need an instance of the Admin Api and an instance of the Ods Api. To set up this environment we execute the `start.ps1` script.

Once this environment is up and running, we run the `e2eTest.ps1` script, which execute the tests.

## Steps to run

1. Create your  `.env` file using the `.env.example` as a reference. This file is used by the `e2eTest.ps1` script.
2. Go to the /docker folder and create your `.env` file using the `.env.example` as a reference. This file is necessary to create the docker containers.
3. Execute the `start.ps1` script, and wait about 10 or 15 seconds.
4. Once the environment is up and running on docker, go back to the `E2E Tests` folder and execute the `e2eTest.ps1` script.

To stop the services, run `start.ps1 -d` (for "down") or `start.ps1 -d -v` to stop and remove volumes.

## Some other notes

1. For now these tests work on a multi-tentant environment.

## Next steps.

1. For now a successful execution is based on the on the `healthy` field. In future iteration we need to think of a more robust validation.
