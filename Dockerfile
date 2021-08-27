FROM mcr.microsoft.com/windows/servercore:ltsc2019

LABEL maintainer="Ingeii"

# Arguments
# ARG BUILD_DATE
# ARG VCS_REF
# ARG BUILD_VERSION

# Labels
LABEL org.label-schema.schema-version="1.0"
# LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="ingeniisolutions/adf-self-hosted-integration-runtime"
LABEL org.label-schema.description="Azure Data Factory - Self-Hosted Integration Runtime"
LABEL org.label-schema.url="https://ingenii.dev"
LABEL org.label-schema.vcs-url="https://github.com/ingenii-solutions/azure-data-factory-self-hosted-runtime"
# LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="Ingenii"
# LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker run -d -e AUTH_KEY="" ingeniisolutions/adf-self-hosted-integration-runtime"

ENV RuntimeDownloadUrl="https://download.microsoft.com/download/E/4/7/E4771905-1079-445B-8BF9-8A1A075D8A10/IntegrationRuntime_5.9.7894.1.msi"

WORKDIR C:/adf-runtime

COPY scripts .

RUN ["powershell", "./build.ps1", "-RuntimeDownloadUrl $env:RuntimeDownloadUrl"]

CMD ["powershell", "./setup.ps1"]

HEALTHCHECK --start-period=120s CMD ["powershell", "/healthcheck.ps1"]