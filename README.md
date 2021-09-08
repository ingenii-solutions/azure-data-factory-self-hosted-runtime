# azure-data-factory-self-hosted-runtime
Azure Data Factory - Self Hosted Integration Runtime Windows Container

## Docker Image Details
* Registry: ingeniisolutions
* Repository: adf-self-hosted-integration-runtime
* Current Version: 1.0.0

## Prerequisites

1. Installation of [Docker CE](https://store.docker.com/search?type=edition&offering=community)
1. Installation of [git SCM](https://git-scm.com/downloads)
1. Windows: to mimic Linux functionality, the programs [Make](http://gnuwin32.sourceforge.net/packages/make.htm) and [sed](http://gnuwin32.sourceforge.net/packages/sed.htm)
    1. Download and install the setup programs from the links above
    1. Next, we need to add the new `make` binary to your PATH environment variable.
        1. In Windows 10, go to `Settings > Edit environment variables for your account`
        1. If you want to change for just your account, you'll want to edit `Path` in the `User variables . . .` box; if for all accounts, edit in the `System variables` box
        1. Choose the `Path` variable, and click `Edit`.
        1. Click `New` and add the full path to the `bin` folder in the `GnuWin32` folder. If you installed in the default location, this is `C:\Program Files (x86)\GnuWin32\bin`
        1. For the changes to take effect, you need to restart or create a new `cmd` window or your IDE

## Set up

1. Complete the 'Getting Started > Prerequisites' section
1. Run `make setup` to copy `.env-dist` > `.env` and populate with values from the `Docker Image Details` section above

## Commands

1. `make build`
1. `make push`
