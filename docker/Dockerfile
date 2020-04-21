FROM openjdk:11.0.1-jre-slim

RUN apt-get update -y && apt-get install -y net-tools curl

VOLUME /tmp

ARG ARTIFACT_NAME
ADD ${ARTIFACT_NAME}.jar /app.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
