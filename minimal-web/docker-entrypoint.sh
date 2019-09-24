#! /bin/sh
echo "JAVA_OPTS = ${JAVA_OPTS}"

exec java ${JAVA_OPTS} -jar /app.jar
