# syntax = docker/dockerfile:1.3

FROM eclipse-temurin:21-jre-jammy

RUN apt-get update && apt-get -y install\
    cron\
    gettext\
    unzip\
    xxd

# hook into docker BuildKit --platform support
# see https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

EXPOSE 25565

ARG APPS_REV=1
ARG GITHUB_BASEURL=https://github.com

ARG EASY_ADD_VERSION=0.8.4
ADD ${GITHUB_BASEURL}/itzg/easy-add/releases/download/${EASY_ADD_VERSION}/easy-add_${TARGETOS}_${TARGETARCH}${TARGETVARIANT} /usr/bin/easy-add
RUN chmod +x /usr/bin/easy-add

ARG RCON_CLI_VERSION=1.6.4
RUN easy-add --var os=${TARGETOS} --var arch=${TARGETARCH}${TARGETVARIANT} \
    --var version=${RCON_CLI_VERSION} --var app=rcon-cli --file {{.app}} \
    --from ${GITHUB_BASEURL}/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz

ARG MC_MONITOR_VERSION=0.12.8
RUN easy-add --var os=${TARGETOS} --var arch=${TARGETARCH}${TARGETVARIANT} \
    --var version=${MC_MONITOR_VERSION} --var app=mc-monitor --file {{.app}} \
    --from ${GITHUB_BASEURL}/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz

ARG MINECRAFT_BACKUP_VERSION=1.2.3
ADD ${GITHUB_BASEURL}/draoncc/minecraft-backup/releases/download/v${MINECRAFT_BACKUP_VERSION}/backup.sh /usr/bin/minecraft-backup
RUN chmod +x /usr/bin/minecraft-backup

ARG FORGE_API_KEY
ARG PROMINENCE_II_RGP_VERSION=2.7.6
RUN curl -H "X-Api-Token: ${FORGE_API_KEY}" https://mediafilez.forgecdn.net/files/5144/709/Prominence_II_RPG_Server_Pack_v${PROMINENCE_II_RGP_VERSION}.zip -o /tmp/modpack.zip &&\
    unzip /tmp/modpack.zip -d /minecraft &&\
    rm /tmp/modpack.zip

COPY --chmod=755 . /minecraft

VOLUME [ "/minecraft/world" "/minecraft/backup" ]
WORKDIR /minecraft

RUN chmod +x start.sh && echo "eula=true" > eula.txt

STOPSIGNAL SIGTERM

ENV UID=1000 GID=1000

CMD [ "./run.sh" ]
HEALTHCHECK --start-period=1m --interval=5s --retries=24 CMD mc-health