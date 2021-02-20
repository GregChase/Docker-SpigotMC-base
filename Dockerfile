FROM ubuntu:latest as build
MAINTAINER Greg Chase <greg@gregchase.com>

#Spigot Build
ENV FILE_BUILDTOOL https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
ARG SPIGOT_VERSION=1.16.5
ENV SPIGOT_REV=${SPIGOT_VERSION}
ENV SPIGOT_BUILD_REV=${SPIGOT_VERSION}

RUN apt-get update && apt-get -y install git tar openjdk-11-jre-headless wget

RUN wget -O BuildTools.jar ${FILE_BUILDTOOL}

RUN java -jar BuildTools.jar --rev ${SPIGOT_BUILD_REV}

FROM adoptopenjdk/openjdk11:jre
ARG MEM="2g"
ENV JVM_OPTS="-Xms${MEM} -Xmx${MEM}"
ENV SPIGOT_OPTS="nogui"
ARG SPIGOT_VERSION=1.16.5
ENV SPIGOT_DIR="/minecraft/server"

RUN mkdir -p ${SPIGOT_DIR}

COPY --from=build /spigot-${SPIGOT_VERSION}.jar /minecraft/spigot.jar
COPY run-spigot.sh /usr/bin/

WORKDIR ${SPIGOT_DIR}

# Expose the standard Minecraft port, and remote console port
EXPOSE 25565
EXPOSE 25575

CMD ["/usr/bin/run-spigot.sh"]
