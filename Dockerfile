
#FROM eclipse-temurin:17-jdk
#WORKDIR /app
#COPY target/deeptrain-backend.jar app.jar
#ENTRYPOINT ["java", "-jar", "app.jar"]

FROM eclipse-temurin:17-jdk

WORKDIR /app
COPY target/deeptrain-backend.jar app.jar

# Expose the EB port dynamically using the PORT env variable
ENV PORT=5000
EXPOSE ${PORT}

# Pass the server.port dynamically from environment
ENTRYPOINT ["sh", "-c", "java -jar app.jar --server.port=${PORT}"]
