# Ed-Fi-Admin-Console-Worker-Process

[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/Ed-Fi-Alliance-OSS/Ed-Fi-Admin-Console-Health-Check-Worker-Process/badge)](https://securityscorecards.dev/viewer/?uri=github.com/Ed-Fi-Alliance-OSS/Ed-Fi-Admin-Console-Health-Check-Worker-Process)

This repository contains a collection of microservices designed to provide different standalone functionalities that can be used in Admin Console. Each microservice is developed independently, with its own configurations and specific documentation.

## Table of Contents

- [General Overview](#general-overview)
- [Available Microservices](#available-microservices)
  - [Health Check](#health-check)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
- [License](#license)

## General Overview

The goal of this repository is to centralize various microservices that can be used for developing applications based on microservices architectures. Each microservice is contained within its own folder and is independent of the others, allowing for easy integration, deployment, and maintenance.

## Available Worker-Processes

### Health Check

The *Health Check* microservice is responsible for verifying the status of Admin Console.

For more details about the *Health Check* microservice, please refer to the documentation file: `docs/healthCheck.md`.

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/Ed-Fi-Alliance-OSS/Ed-Fi-Admin-Console-Services.git

## Contributing

The Ed-Fi Alliance welcomes code contributions from the community. Please read
the [Ed-Fi Contribution
Guidelines](https://techdocs.ed-fi.org/display/ETKB/Code+Contribution+Guidelines)
for detailed information on how to contribute source code.

Looking for an easy way to get started? Search for tickets with label
"up-for-grabs" in [Tracker](https://tracker.ed-fi.org/issues/?filter=14106);
these are nice-to-have but low priority tickets that should not require in-depth
knowledge of the code base and architecture.

## Legal Information

Copyright (c) 2023 Ed-Fi Alliance, LLC and contributors.

Licensed under the [Apache License, Version 2.0](LICENSE) (the "License").

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

See [NOTICES](NOTICES.md) for additional copyright and license notifications.
