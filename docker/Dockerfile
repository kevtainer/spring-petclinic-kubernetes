FROM openjdk:10.0.2-jre-slim

VOLUME /tmp

RUN wget -O /dd-java-agent.jar 'https://search.maven.org/classic/remote_content?g=com.datadoghq&a=dd-java-agent&v=LATEST'

ARG ARTIFACT_NAME
ADD ${ARTIFACT_NAME}.jar /app.jar

ENTRYPOINT ["java","-javaagent:/dd-java-agent.jar","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
