# Azure Data Factory - Self-Hosted Integration Runtime Windows Container

[![Maintainer](https://img.shields.io/badge/maintainer%20-ingenii-orange?style=flat)](https://ingenii.dev/)
[![License](https://img.shields.io/badge/license%20-MIT-orange?style=flat)](https://github.com/ingenii-solutions/azure-data-factory-self-hosted-runtime/blob/main/LICENSE)
[![Contributing](https://img.shields.io/badge/howto%20-contribute-blue?style=flat)](https://github.com/ingenii-solutions/azure-data-factory-self-hosted-runtime/blob/main/CONTRIBUTING.md)

## Table of Contents
- [Azure Data Factory - Self-Hosted Integration Runtime Windows Container](#azure-data-factory---self-hosted-integration-runtime-windows-container)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Version Matrix](#version-matrix)
  - [Docker Hub](#docker-hub)
  - [Prerequisites](#prerequisites)
  - [Environment Variables](#environment-variables)
  - [Usage](#usage)
    - [Docker Compose (Preferred)](#docker-compose-preferred)
      - [Step 1 - Clone this repository](#step-1---clone-this-repository)
      - [Step 2 - Prepare Environment Variables (env.dist -> .env)](#step-2---prepare-environment-variables-envdist---env)
      - [Step 3 - Choose your Docker Compose template](#step-3---choose-your-docker-compose-template)
      - [Step 4 - Run Docker Compose](#step-4---run-docker-compose)
      - [Helpful Commands](#helpful-commands)
    - [Docker CLI](#docker-cli)
      - [Run Only (do not detach)](#run-only-do-not-detach)
      - [Run and Detach](#run-and-detach)
  - [Troubleshooting](#troubleshooting)
    - [Error Code 1847](#error-code-1847)
      - [Solution](#solution)
    - [Error Code 1500](#error-code-1500)
      - [Solution](#solution-1)
    - [Error SQLSTATE IM004, SQLAllocHandle on SQL_HANDLE_ENV](#error-sqlstate-im004-sqlallochandle-on-sql_handle_env)
      - [Solution](#solution-2)
  - [Thanks](#thanks)
  - [Future Improvements](#future-improvements)

## Overview

This is a working solution on how to use Azure Data Factory Self-Hosted Integration Runtime running inside a Windows container.

## Version Matrix

| Image Version  | ADF Self-Hosted Runtime Version | Bundled Drivers            |
| -------------- | ------------------------------- | -------------------------- |
| 1.0.0          | 5.10.7918.2                     | N/A                        |
| 1.0.1 (latest) | 5.12.7984.1                     | IBM DB2 ODBC Driver 5.11.4 |

## Docker Hub

You can find a pre-built version of the image in our Docker Hub account:

[Ingenii Solutions](https://hub.docker.com/r/ingeniisolutions/adf-self-hosted-integration-runtime/tags)

## Prerequisites

1. Installation of [Docker CE](https://store.docker.com/search?type=edition&offering=community)
2. Installation of [git SCM](https://git-scm.com/downloads)

## Environment Variables

Below are the environment variables the image understands.

| Variable                                   | Default              | Description                                                                                                                                                               |
| ------------------------------------------ | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AUTH_KEY                                   | No (Required)        | The [ADF authentication key](https://docs.microsoft.com/en-us/azure/data-factory/create-self-hosted-integration-runtime?tabs=data-factory#create-a-self-hosted-ir-via-ui) |
| NODE_NAME                                  | `container hostname` | The name of the node that will be displayed in ADF.                                                                                                                       |
| OFFLINE_NODE_AUTO_DELETION_TIME_IN_SECONDS | `601` (10 minutes)   | The number of seconds that a node has to be offline to be automatically cleaned up from ADF. (it has to be the same for all nodes in the same runtime)                    |
| ENABLE_HA                                  | `false`              | If you are planning to use multiple containers (nodes) in a single runtime, please set this to true.                                                                     |
| HA_PORT                                    | `8060`               | The HA port used for communication between the nodes.                                                                                                                     |

## Usage

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
docker-compose -f docker-compose.<template>.yml up -d
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

## Troubleshooting

### Error Code 1847

```shell
A service error occurred (StatusCode: 400; ErrorCode: 1847; ActivityId: 7c596324-5649-4859-aedc-c700611339df; ErrorMessage: OfflineNodeAutoDeletionTimeInSeconds should be same among the SHIR nodes and it should be 601.).    
```

#### Solution

All nodes in a runtime have to have the same value for `OFFLINE_NODE_AUTO_DELETION_TIME_IN_SECONDS` enviornment variable.
Also, if you are to have more than one node, you need to set ENABLE_HA to `true`.

### Error Code 1500

```shell
 A service error occurred (StatusCode: 400; ErrorCode: 1500; ActivityId: 54ed9ef2-cedd-4e9c-93b4-650ee527e862; ErrorMessage: Exception of type 'Microsoft.DataTransfer.GatewayService.Client.GatewayServiceException' was thrown.)
```

#### Solution

You most likely have 4 registered nodes with the current runtime. Azure Data Factory supports only 4 registered nodes per integration runtime.

### Error SQLSTATE IM004, SQLAllocHandle on SQL_HANDLE_ENV

Applies to: IBM DB2 ODBC Driver Only

The error is generated whenever the docker image is executed with [isolation mode](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/hyperv-container) set to `hyperv` and not `process`.  
This typically occurs on Windows Desktop OS as that defaults to isolated: hyperv mode and Windows Server OS defaults to isolated: process mode. 

#### Solution

If you are going to be using IBM DB2 ODBC Driver, it is highly suggested to run the image inside Windows Server 2019 or above. [Isolation mode](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/hyperv-container) should be set to `process`.



## Thanks

This repository was heavily inspired by what was already done [here](https://github.com/Azure/Azure-Data-Factory-Integration-Runtime-in-Windows-Container) by [@wxygeek](https://github.com/wxygeek)

## Future Improvements

- [ ] Add a Github workflow to automatically build and publish new versions
- [ ] Add a self-termiantion logic that would automatically terminate the Docker Host instance if running in Azure or AWS. This would help in scenarios where the self-hosted integration runtime is deployed via Azure Functions/Lambda only for a job that is needed and then automatically terminated when no jobs are pending for execution. There isn't any better way of using the Docker image natively in Azure/AWS with the benefit of VNET/VPC integration and keeping the costs low by terminating the instance after every run.
