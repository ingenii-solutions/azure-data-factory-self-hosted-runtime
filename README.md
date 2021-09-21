# Azure Data Factory - Self-Hosted Integration Runtime Windows Container

[![Maintainer](https://img.shields.io/badge/maintainer%20-ingenii-orange?style=flat)](https://ingenii.dev/)
[![License](https://img.shields.io/badge/license%20-MIT-orange?style=flat)](https://github.com/ingenii-solutions/azure-data-factory-self-hosted-runtime/blob/main/LICENSE)
[![Contributing](https://img.shields.io/badge/howto%20-contribute-blue?style=flat)](https://github.com/ingenii-solutions/azure-data-factory-self-hosted-runtime/blob/main/CONTRIBUTING.md)


## Overview

This is a working solution on how to use Azure Data Factory Self-Hosted Integration Runtime running inside a Windows container.

## Version Matrix

| Image Version  | ADF Self-Hosted Runtime Version |
| -------------- | ------------------------------- |
| 1.0.0 (latest) | 5.10.7918.2                     |

## Docker Hub

You can find a pre-built vesion of the image in our Docker Hub account:

[Ingenii Solutions](https://hub.docker.com/r/ingeniisolutions/adf-self-hosted-integration-runtime/tags)

## Prerequisites

1. Installation of [Docker CE](https://store.docker.com/search?type=edition&offering=community)
2. Installation of [git SCM](https://git-scm.com/downloads)

## Environment Variables

| Variable                                   | Default              | Description                                                                                                                                                               |
| ------------------------------------------ | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AUTH_KEY                                   | No (Required)        | The [ADF authentication key](https://docs.microsoft.com/en-us/azure/data-factory/create-self-hosted-integration-runtime?tabs=data-factory#create-a-self-hosted-ir-via-ui) |
| NODE_NAME                                  | `container hostname` | The name of the node that will be displayed in ADF.                                                                                                                       |
| OFFLINE_NODE_AUTO_DELETION_TIME_IN_SECONDS | `601` (10 minutes)   | The number of seconds that a node has to be offline to be automatically cleaned up from ADF. (it has to be the same for all nodes in the same runtime)                    |
| ENABLE_HA                                  | `false`              | If you are planning to use multiple containers (nodes) in a single runtime, pleasae set this to true.                                                                     |
| HA_PORT                                    | `8060`               | The HA port used for communication between the nodes.                                                                                                                     |

## Usage                                                                                                                |

### Docker Compose (Preferred)

#### Step 1 - Clone this repository

```shell
git clone https://github.com/ingenii-solutions/azure-data-factory-self-hosted-runtime.git
```

#### Step 2 - Prepare Environment Variables (env.dist -> .env)

```shell
cp .env.dist .env
```

Add your Azure Data Factory Authentication Keys (connection strings) to each variable:

```shell
# Azure Data Factory Connection Strings
PRODUCTION_CONNECTION_STRING="<add prod auth key here>"
TEST_CONNECTION_STRING="<add test auth key here>" # Optional
DEV_CONNECTION_STRING="<add dev auth key here>" # Optional
```

#### Step 3 - Choose your Docker Compose template

We have the following templates available:

| Template            | Filename                  | Descripton                                                                            |
| ------------------- | ------------------------- | ------------------------------------------------------------------------------------- |
| Single              | docker-compose.single.yml | Single container deployment. Needs only the `PRODUCTION_CONNECTION_STRING` to be set. |
| Dev,Test,Prod (DTP) | docker-compose.dtp.yml    | Multi-environment deployment. Needs all connection string variables set.              |

#### Step 4 - Run Docker Compose

```shell
docker-compose -f docker-compose.<template>.yml -d
```

You can monitor the status of the container(s) by using `docker-compose ps` command.

#### Helpful Commands

* `docker-compose -f <filename> logs` - View output from containers
* `docker-compose -f <filename> restart` - Restart containers
* `docker-compose -f <filename> down` - Stop and remove resources

### Docker CLI

You can also use the docker cli directly to start the container. Here are some examples:

#### Run Only (do not detach)

```shell
docker run -e AUTH_KEY="IR@xxx" -e ENABLE_HA=true ingeniisolutions/adf-self-hosted-integration-runtime
```

#### Run and Detach

```shell
docker run -d -e AUTH_KEY="IR@xxx" -e ENABLE_HA=true ingeniisolutions/adf-self-hosted-integration-runtime
```

## Thanks

This repository was heavily inspired by what was already done [here](https://github.com/Azure/Azure-Data-Factory-Integration-Runtime-in-Windows-Container) by [@wxygeek](https://github.com/wxygeek)

