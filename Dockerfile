FROM mcr.microsoft.com/windows/servercore:ltsc2019

LABEL maintainer="Ingeii"

ENV RUNTIME_DOWNLOAD_URL="https://download.microsoft.com/download/E/4/7/E4771905-1079-445B-8BF9-8A1A075D8A10/IntegrationRuntime_5.12.7984.1.msi"

WORKDIR "C:/adf-runtime"

COPY scripts .
COPY drivers ./drivers

RUN ["powershell", "./install-runtime.ps1", "-RuntimeDownloadUrl $env:RUNTIME_DOWNLOAD_URL"]
RUN ["powershell", "./install-drivers.ps1"]
CMD ["powershell", "./entrypoint.ps1"]

HEALTHCHECK --start-period=120s CMD ["powershell", "./healthcheck.ps1"]