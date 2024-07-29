FROM maven:3.8.1-openjdk-17-slim AS build
WORKDIR /app

COPY src /app/src
COPY pom.xml /app/
COPY lib/libarx-3.9.1.jar /app/lib/

RUN mvn install:install-file -Dfile=/app/lib/libarx-3.9.1.jar -DgroupId=org.deidentifier.arx -DartifactId=arx -Dversion=3.9.1 -Dpackaging=jar
RUN mvn clean install -DskipTests

FROM openjdk:17-slim
WORKDIR /app

COPY --from=build /app/target/anonymization-service-1.0-SNAPSHOT.jar /app/anonymization-service.jar

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "/app/anonymization-service.jar"]
