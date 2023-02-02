FROM mcr.microsoft.com/windows/servercore:ltsc2019

LABEL maintainer="Ingeii"

ENV RUNTIME_DOWNLOAD_URL="https://go.microsoft.com/fwlink/?linkid=839822&clcid=0x409"

WORKDIR "C:/adf-runtime"

COPY scripts .
COPY drivers ./drivers

RUN ["powershell", "./install-runtime.ps1", "-RuntimeDownloadUrl $env:RUNTIME_DOWNLOAD_URL"]
RUN ["powershell", "./install-drivers.ps1"]
CMD ["powershell", "./entrypoint.ps1"]

HEALTHCHECK --start-period=120s CMD ["powershell", "./healthcheck.ps1"]