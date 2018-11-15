FROM openjdk:11-jre-slim

VOLUME /tmp

RUN apt-get update && apt-get install -y wget && \
  wget -O /dd-java-agent.jar 'https://search.maven.org/classic/remote_content?g=com.datadoghq&a=dd-java-agent&v=LATEST'

ARG ARTIFACT_NAME
ADD ${ARTIFACT_NAME}.jar /app.jar

ENTRYPOINT ["java","-javaagent:/dd-java-agent.jar","-Dnet.bytebuddy.experimental=true","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
