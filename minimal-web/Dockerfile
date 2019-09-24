FROM openjdk:8-jdk

COPY . /app
WORKDIR /app

RUN ./gradlew clean test bootJar

FROM openjdk:8-jre-alpine

COPY --from=0 /app/build/libs/minimal-web-0.0.1-SNAPSHOT.jar /app.jar
COPY docker-entrypoint.sh /
EXPOSE 8080

CMD ["/docker-entrypoint.sh"]
