FROM mcr.microsoft.com/windows/servercore:ltsc2019

LABEL maintainer="Ingeii"

ENV RUNTIME_DOWNLOAD_URL="https://download.microsoft.com/download/E/4/7/E4771905-1079-445B-8BF9-8A1A075D8A10/IntegrationRuntime_5.10.7918.2.msi"

WORKDIR "C:/adf-runtime"

COPY scripts .

RUN ["powershell", "./build.ps1", "-RuntimeDownloadUrl $env:RUNTIME_DOWNLOAD_URL"]

CMD ["powershell", "./entrypoint.ps1"]

HEALTHCHECK --start-period=120s CMD ["powershell", "./healthcheck.ps1"]