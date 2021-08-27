FROM mcr.microsoft.com/windows/servercore:ltsc2019

ENV RuntimeDownloadUrl="https://download.microsoft.com/download/E/4/7/E4771905-1079-445B-8BF9-8A1A075D8A10/IntegrationRuntime_5.9.7894.1.msi"

WORKDIR C:/adf-runtime

COPY scripts .

RUN ["powershell", "./build.ps1", "-RuntimeDownloadUrl $env:RuntimeDownloadUrl"]

# CMD ["powershell", "C:/shir/scripts/setup.ps1"]

# ENV SHIR_WINDOWS_CONTAINER_ENV True

# HEALTHCHECK --start-period=120s CMD ["powershell", "C:/shir/scripts/health-check.ps1"]