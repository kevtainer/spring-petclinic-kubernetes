FROM openjdk:11-jre-slim

VOLUME /tmp

ARG ARTIFACT_NAME
ADD ${ARTIFACT_NAME}.jar /app.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
